```bash
helm uninstall observability-opensearch

for i in `kubectl get pods | awk '{print $1}'` ; do kubectl delete pod $i --force ; done

helm upgrade observability-opensearch . --install -f values.yaml
```