#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Copy one IPT datadir from DigitalOcean PVC to NIRD shared PVC.

Usage:
  copy_from_do_pvc_to_nird.sh <release>

Releases:
  main | corema | slovakia | ukraine | test

Environment overrides:
  DO_CONTEXT           (default: do-ams3-k8s-1-22-8-do-1-ams3-1653000194710)
  DO_NAMESPACE         (default: default)
  NIRD_CONTEXT         (default: nird-lmd)
  NIRD_NAMESPACE       (default: gbif-no-ns8095k)
  NIRD_SHARED_PVC      (default: 573890b9-3346-4027-ab0c-22eec6dfd665)
  DO_PVC_CLAIM         (default: <release>-pvc-retain)
  NIRD_SUBPATH         (default: ipt-<release>)
  WIPE_TARGET          (default: true)
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

DO_CONTEXT="${DO_CONTEXT:-do-ams3-k8s-1-22-8-do-1-ams3-1653000194710}"
DO_NAMESPACE="${DO_NAMESPACE:-default}"
NIRD_CONTEXT="${NIRD_CONTEXT:-nird-lmd}"
NIRD_NAMESPACE="${NIRD_NAMESPACE:-gbif-no-ns8095k}"
NIRD_SHARED_PVC="${NIRD_SHARED_PVC:-573890b9-3346-4027-ab0c-22eec6dfd665}"
DO_PVC_CLAIM="${DO_PVC_CLAIM:-${RELEASE}-pvc-retain}"
NIRD_SUBPATH="${NIRD_SUBPATH:-ipt-${RELEASE}}"
WIPE_TARGET="${WIPE_TARGET:-true}"

stamp="$(date +%s)"
DO_HELPER_POD="do-copy-${RELEASE}-${stamp}"
NIRD_HELPER_POD="nird-copy-${RELEASE}-${stamp}"
TARGET_DIR="/pvc/${NIRD_SUBPATH}"

cleanup() {
  kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" delete pod "$DO_HELPER_POD" --ignore-not-found >/dev/null 2>&1 || true
  kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" delete pod "$NIRD_HELPER_POD" --ignore-not-found >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Creating helper pod in DO: $DO_HELPER_POD"
cat <<EOF | kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${DO_HELPER_POD}
spec:
  restartPolicy: Never
  containers:
    - name: helper
      image: alpine:3.20
      command: ["sh", "-c", "sleep 36000"]
      volumeMounts:
        - name: ipt-data
          mountPath: /source
  volumes:
    - name: ipt-data
      persistentVolumeClaim:
        claimName: ${DO_PVC_CLAIM}
EOF

echo "Creating helper pod in NIRD: $NIRD_HELPER_POD"
cat <<EOF | kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: ${NIRD_HELPER_POD}
spec:
  restartPolicy: Never
  containers:
    - name: helper
      image: alpine:3.20
      command: ["sh", "-c", "sleep 36000"]
      volumeMounts:
        - name: shared-data
          mountPath: /pvc
  volumes:
    - name: shared-data
      persistentVolumeClaim:
        claimName: ${NIRD_SHARED_PVC}
EOF

kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" wait --for=condition=Ready "pod/${DO_HELPER_POD}" --timeout=180s >/dev/null
kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" wait --for=condition=Ready "pod/${NIRD_HELPER_POD}" --timeout=180s >/dev/null

kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec "$NIRD_HELPER_POD" -- sh -lc "mkdir -p '$TARGET_DIR'"
if [[ "$WIPE_TARGET" == "true" ]]; then
  echo "Wiping NIRD target: $TARGET_DIR"
  kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec "$NIRD_HELPER_POD" -- sh -lc "find '$TARGET_DIR' -mindepth 1 -maxdepth 1 -exec rm -rf {} +"
fi

echo "Copying data stream DO:/source -> NIRD:${TARGET_DIR}"
kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" exec "$DO_HELPER_POD" -- sh -lc "tar cf - -C /source ." \
  | kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec -i "$NIRD_HELPER_POD" -- sh -lc "tar xf - -C '$TARGET_DIR'"

src_files="$(kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" exec "$DO_HELPER_POD" -- sh -lc "find /source -type f | wc -l" | tr -d '[:space:]')"
dst_files="$(kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec "$NIRD_HELPER_POD" -- sh -lc "find '$TARGET_DIR' -type f | wc -l" | tr -d '[:space:]')"
src_kb="$(kubectl --context "$DO_CONTEXT" -n "$DO_NAMESPACE" exec "$DO_HELPER_POD" -- sh -lc "du -sk /source | awk '{print \$1}'" | tr -d '[:space:]')"
dst_kb="$(kubectl --context "$NIRD_CONTEXT" -n "$NIRD_NAMESPACE" exec "$NIRD_HELPER_POD" -- sh -lc "du -sk '$TARGET_DIR' | awk '{print \$1}'" | tr -d '[:space:]')"

echo "Copy complete for ${RELEASE}"
echo "Source files: ${src_files}, target files: ${dst_files}"
echo "Source size: ${src_kb} KiB, target size: ${dst_kb} KiB"
