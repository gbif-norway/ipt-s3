# IPT-S3 (NIRD)

This repository contains the live NIRD manifests for IPT deployments (`k8s/nird/`).

Current production hosts:

- `ipt.gbif.no`
- `corema.ipt.gbif.no`
- `slovakia.ipt.gbif.no`
- `ukraine.ipt.gbif.no`

Test host:

- `test.ipt.gbif.no`

## Runtime Model

- Platform: NIRD (`nird-lmd` context, namespace `gbif-no-ns8095k`)
- App image: `gbif/ipt:<tag>`
- Shared PVC: `573890b9-3346-4027-ab0c-22eec6dfd665` with per-release subPaths
- No sidecar in production

## Deploy to NIRD

1. Update IPT image tags in:
   - `k8s/nird/01-main.yaml`
   - `k8s/nird/02-corema.yaml`
   - `k8s/nird/03-slovakia.yaml`
   - `k8s/nird/04-ukraine.yaml`
   - `k8s/nird/05-test.yaml`
2. Apply all IPT manifests:

```bash
kubectl --context nird-lmd apply -k k8s/nird
```

3. Wait for rollouts:

```bash
kubectl --context nird-lmd -n gbif-no-ns8095k rollout status deploy/main-ipt
kubectl --context nird-lmd -n gbif-no-ns8095k rollout status deploy/corema-ipt
kubectl --context nird-lmd -n gbif-no-ns8095k rollout status deploy/slovakia-ipt
kubectl --context nird-lmd -n gbif-no-ns8095k rollout status deploy/ukraine-ipt
kubectl --context nird-lmd -n gbif-no-ns8095k rollout status deploy/test-ipt
```

4. Verify running image tags:

```bash
kubectl --context nird-lmd -n gbif-no-ns8095k get deploy main-ipt corema-ipt slovakia-ipt ukraine-ipt test-ipt \
  -o jsonpath='{range .items[*]}{.metadata.name}{" => "}{.spec.template.spec.containers[0].image}{"\n"}{end}'
```

## Rollback

```bash
kubectl --context nird-lmd -n gbif-no-ns8095k set image deploy/main-ipt main-ipt=gbif/ipt:<previous-tag>
kubectl --context nird-lmd -n gbif-no-ns8095k set image deploy/corema-ipt corema-ipt=gbif/ipt:<previous-tag>
kubectl --context nird-lmd -n gbif-no-ns8095k set image deploy/slovakia-ipt slovakia-ipt=gbif/ipt:<previous-tag>
kubectl --context nird-lmd -n gbif-no-ns8095k set image deploy/ukraine-ipt ukraine-ipt=gbif/ipt:<previous-tag>
kubectl --context nird-lmd -n gbif-no-ns8095k set image deploy/test-ipt test-ipt=gbif/ipt:<previous-tag>
```

## Notes

- `k8s/nird/scripts/` contains historical migration helpers and is not required for routine deployments.
