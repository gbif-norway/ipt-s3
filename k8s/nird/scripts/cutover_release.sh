#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Controlled IPT cutover for one release:
  1) scales DO deployment to 0
  2) copies PVC data from DO to NIRD
  3) scales NIRD deployment to 1
  4) runs basic smoke checks against NIRD ingress IP

Usage:
  cutover_release.sh <release>

Releases:
  main | corema | slovakia | ukraine | test
EOF
}

RELEASE="${1:-}"
if [[ -z "$RELEASE" ]]; then
  usage
  exit 1
fi

case "$RELEASE" in
  main|corema|slovakia|ukraine|test) ;;
  *)
    echo "Unsupported release: $RELEASE" >&2
    usage
    exit 1
    ;;
esac

declare -A HOST_BY_RELEASE=(
  [main]="ipt.gbif.no"
  [corema]="corema.ipt.gbif.no"
  [slovakia]="slovakia.ipt.gbif.no"
  [ukraine]="ukraine.ipt.gbif.no"
  [test]="test.ipt.gbif.no"
)

declare -A INSTALLATION_KEY_BY_RELEASE=(
  [main]="c4e83f8a-f24c-4573-a197-f085ca242917"
  [corema]="2b558ef8-e325-4e87-9fcd-198dcf110ab8"
  [slovakia]="e6fc90b9-c84e-4e11-b235-aa8ffd1e0832"
  [ukraine]="d0e2b9a9-8496-4959-8cba-a7fea22537eb"
  [test]="a2558cde-7eab-499b-acbe-24115092a743"
)

HOST="${HOST_BY_RELEASE[$RELEASE]}"
EXPECTED_INSTALLATION_KEY="${INSTALLATION_KEY_BY_RELEASE[$RELEASE]}"

DO_CONTEXT="${DO_CONTEXT:-do-ams3-k8s-1-22-8-do-1-ams3-1653000194710}"
DO_NAMESPACE="${DO_NAMESPACE:-default}"
NIRD_CONTEXT="${NIRD_CONTEXT:-nird-lmd}"
NIRD_NAMESPACE="${NIRD_NAMESPACE:-gbif-no-ns8095k}"
NIRD_SHARED_PVC="${NIRD_SHARED_PVC:-573890b9-3346-4027-ab0c-22eec6dfd665}"

DO_DEPLOYMENT="${DO_DEPLOYMENT:-${RELEASE}-ipt}"
NIRD_DEPLOYMENT="${NIRD_DEPLOYMENT:-${RELEASE}-ipt}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

echo "Release: ${RELEASE}"
echo "Host: ${HOST}"
echo "DO deployment: ${DO_DEPLOYMENT} (${DO_CONTEXT}/${DO_NAMESPACE})"
echo "NIRD deployment: ${NIRD_DEPLOYMENT} (${NIRD_CONTEXT}/${NIRD_NAMESPACE})"
echo "NIRD shared PVC: ${NIRD_SHARED_PVC}"
echo
read -r -p "Type CUTOVER to continue: " confirmation
if [[ "$confirmation" != "CUTOVER" ]]; then
  echo "Aborted"
  exit 1
fi

echo "Scaling DO deployment to 0: ${DO_DEPLOYMENT}"
kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" scale deployment "$DO_DEPLOYMENT" --replicas=0

echo "Waiting for DO pods to terminate"
for _ in $(seq 1 60); do
  pod_count="$(kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" get pods -l "app=${RELEASE}-ipt" --no-headers 2>/dev/null | wc -l | tr -d '[:space:]')"
  if [[ "$pod_count" == "0" ]]; then
    break
  fi
  sleep 2
done

pod_count="$(kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" get pods -l "app=${RELEASE}-ipt" --no-headers 2>/dev/null | wc -l | tr -d '[:space:]')"
if [[ "$pod_count" != "0" ]]; then
  echo "DO pods still running for ${RELEASE}; refusing to continue" >&2
  exit 1
fi

echo "Copying DO PVC data to NIRD"
DO_CONTEXT="$DO_CONTEXT" \
DO_NAMESPACE="$DO_NAMESPACE" \
NIRD_CONTEXT="$NIRD_CONTEXT" \
NIRD_NAMESPACE="$NIRD_NAMESPACE" \
NIRD_SHARED_PVC="$NIRD_SHARED_PVC" \
"$SCRIPT_DIR/copy_from_do_pvc_to_nird.sh" "$RELEASE"

echo "Scaling NIRD deployment to 1: ${NIRD_DEPLOYMENT}"
kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" scale deployment "$NIRD_DEPLOYMENT" --replicas=1
kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" rollout status "deployment/${NIRD_DEPLOYMENT}" --timeout=600s

NIRD_POD="$(kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" get pod -l "app=${RELEASE}-ipt" -o jsonpath='{.items[0].metadata.name}')"
NIRD_IPT_BASEURL="$(kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec "$NIRD_POD" -c "${RELEASE}-ipt" -- sh -lc "sed -n 's/^ipt.baseURL=//p' /srv/ipt/config/ipt.properties" | tr -d '\r')"
NIRD_IPT_KEY="$(kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec "$NIRD_POD" -c "${RELEASE}-ipt" -- sh -lc "sed -n '/<ipt>/,/<\\/ipt>/p' /srv/ipt/config/registration2.xml | sed -n 's@.*<key>\\(.*\\)</key>.*@\\1@p' | head -n1" | tr -d '\r')"

echo "NIRD ipt.baseURL: ${NIRD_IPT_BASEURL}"
echo "NIRD installation key: ${NIRD_IPT_KEY}"
if [[ "$NIRD_IPT_KEY" != "$EXPECTED_INSTALLATION_KEY" ]]; then
  echo "WARNING: installation key mismatch (expected ${EXPECTED_INSTALLATION_KEY})" >&2
fi

NIRD_INGRESS_IP="$(kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" get ingress "$NIRD_DEPLOYMENT" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
if [[ -n "$NIRD_INGRESS_IP" ]]; then
  echo "NIRD ingress IP: ${NIRD_INGRESS_IP}"
  echo "Smoke check via NIRD ingress IP + Host header"
  curl -sk --resolve "${HOST}:443:${NIRD_INGRESS_IP}" "https://${HOST}/rss.do" | head -n 5 || true
  echo "Current DNS for ${HOST}:"
  dig +short "$HOST" || true
  echo "Update DNS for ${HOST} to ${NIRD_INGRESS_IP} when ready."
else
  echo "Could not resolve NIRD ingress IP for ${NIRD_DEPLOYMENT}; check ingress status manually." >&2
fi

echo "Cutover steps complete for ${RELEASE}."
