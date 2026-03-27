# GBIF IPT Migration to NIRD (No Sidecar)

This directory contains Kubernetes manifests and cutover scripts for moving the live IPT deployments from DigitalOcean (DO) to NIRD.

The NIRD version intentionally runs **IPT only**.  
No sidecar is needed on NIRD because storage backup is handled by the platform PVC backup policy.

## Deployments Covered

- `main` -> `ipt.gbif.no`
- `corema` -> `corema.ipt.gbif.no`
- `slovakia` -> `slovakia.ipt.gbif.no`
- `ukraine` -> `ukraine.ipt.gbif.no`

`test` is supported by scripts for rehearsal, but is not included in the NIRD manifests by default.

## Why This Is Safe for GBIF Registry

The critical identity is in `/srv/ipt/config/registration2.xml` and `/srv/ipt/config/ipt.properties`:

- IPT installation key
- IPT base URL
- org credentials/state

Because we copy `/srv/ipt` from DO and keep the same hostnames, the registry and dataset endpoints remain consistent after DNS cutover.

## Manifest Design

- Namespace: `gbif-no-ns8095k`
- One deployment/service/ingress/networkpolicy per IPT
- `replicas: 1` to reflect current live state after cutover
- Shared PVC claim mounted with per-release `subPath`:
  - `ipt-main`
  - `ipt-corema`
  - `ipt-slovakia`
  - `ipt-ukraine`

Current shared PVC claim in these manifests is:

- `573890b9-3346-4027-ab0c-22eec6dfd665`

If this claim changes, update it in `01-main.yaml`, `02-corema.yaml`, `03-slovakia.yaml`, `04-ukraine.yaml`.

## 1) Apply Manifests

```sh
kubectl --context nird-lmd apply -k k8s/nird
kubectl --context nird-lmd -n gbif-no-ns8095k get deploy,svc,ingress,networkpolicy | grep -- '-ipt'
```

## 2) Cut Over One Release

Use the release cutover script:

```sh
chmod +x k8s/nird/scripts/*.sh
./k8s/nird/scripts/cutover_release.sh main
```

What it does:

1. Scales the DO deployment down to 0.
2. Mounts DO PVC in a helper pod.
3. Mounts NIRD shared PVC in a helper pod.
4. Copies `/srv/ipt` data DO -> NIRD subpath.
5. Scales NIRD deployment to 1.
6. Verifies `ipt.baseURL` and installation key in NIRD pod.
7. Performs a smoke check against NIRD ingress IP using `--resolve`.
8. Prints DNS guidance.

Repeat for:

```sh
./k8s/nird/scripts/cutover_release.sh corema
./k8s/nird/scripts/cutover_release.sh slovakia
./k8s/nird/scripts/cutover_release.sh ukraine
```

## 3) Optional Rehearsal on `test`

The copy/cutover scripts support `test`:

```sh
./k8s/nird/scripts/cutover_release.sh test
```

To run `test` on NIRD, add a `test` manifest equivalent to the 4 production files.

## 4) Post-Cutover Checks

For each host:

- `https://<host>/`
- `https://<host>/rss.do`
- A known resource endpoint:
  - `https://<host>/resource?r=<shortname>`
  - `https://<host>/eml.do?r=<shortname>`
  - `https://<host>/archive.do?r=<shortname>`

Also verify in pod:

```sh
kubectl --context nird-lmd -n gbif-no-ns8095k exec -it <pod> -c <release>-ipt -- \
  sh -lc "sed -n 's/^ipt.baseURL=//p' /srv/ipt/config/ipt.properties"
```

## Low-Risk Order

Recommended migration order:

1. `corema`
2. `slovakia`
3. `ukraine`
4. `main` (last)

This keeps the highest-traffic publishing host (`ipt.gbif.no`) for last.
