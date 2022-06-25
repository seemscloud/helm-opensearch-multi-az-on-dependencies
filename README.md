```bash
helm uninstall observability-opensearch
kubectl delete pods `kubectl  get pods | awk '{print $1}' | tail -n +2` --force
helm upgrade --install observability-opensearch . -f values.yaml
```