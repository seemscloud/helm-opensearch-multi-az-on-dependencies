```bash
helm upgrade observability-opensearch . --install -f values.yaml --recreate-pods
kubectl delete pods `kubectl  get pods | awk '{print $1}' | tail -n +2 | xargs` --force
```