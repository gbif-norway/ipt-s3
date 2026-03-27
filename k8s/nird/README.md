# NIRD IPT Manifests

This directory contains the live Kubernetes manifests for:

- `ipt.gbif.no` (`01-main.yaml`)
- `corema.ipt.gbif.no` (`02-corema.yaml`)
- `slovakia.ipt.gbif.no` (`03-slovakia.yaml`)
- `ukraine.ipt.gbif.no` (`04-ukraine.yaml`)

Apply all IPT resources:

```bash
kubectl --context nird-lmd apply -k k8s/nird
```

Full build/deploy/rollback instructions are in the repository root:

- `README.md`
