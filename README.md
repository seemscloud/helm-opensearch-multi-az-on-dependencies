```bash
helm upgrade observability-opensearch . --install -f values.yaml --recreate-pods
kubectl delete pods `kubectl  get pods | awk '{print $1}' | tail -n +2 | xargs` --force
```

```bash
./plugins/opensearch-security/tools/securityadmin.sh \
    -icl -nhnv -rev \
    -cacert config/certs/admin-ca.crt.pem \
    -cert config/certs/admin.crt.pem \
    -key config/certs/admin.key.pem \
    -cd plugins/opensearch-security/securityconfig
````

```bash
cat > server.sh << "EndOfMessage"
#!/bin/bash

for i in `seq 1 100000` ; do
  echo 'Lorem Ipsum is simply dummy text of the printing and typesetting industry.' >> /tmp/server.log
done
EndOfMessage

for POD in `kubectl get pods | grep -i filebeat | awk '{print $1}'` ; do 
  echo "Begin: ${POD}"
  kubectl exec -it "${POD}" -- /bin/bash -c "`cat server.sh`"
  echo "End: ${POD}"
done
```

```yaml
extraInitContainers:
  - name: sysctl
    image: docker.io/bitnami/bitnami-shell:10-debian-10-r199
    imagePullPolicy: "IfNotPresent"
    command:
      - /bin/bash
      - -ec
      - |
        sysctl -w vm.max_map_count=262144;

    securityContext:
      runAsUser: 0
      privileged: true
```

```yaml
requiredDuringSchedulingIgnoredDuringExecution:
  nodeSelectorTerms:
    - matchExpressions:
        - key: topology.kubernetes.io/zone
          operator: In
          values: [ "az1" ]
```

```yaml
logstash.yml: |-
  http.host: 0.0.0.0
  pipeline.ecs_compatibility: disabled

pipelines.yml: |-
  - pipeline.id: ingest
    pipeline.workers: 1
    pipeline.batch.size: 100
    pipeline.batch.delay: 50
    pipeline.ecs_compatibility: disabled
    pipeline.ordered: false
    queue.type: memory
    path.config: "/usr/share/logstash/pipeline"
    config.reload.automatic: true
    config.reload.interval: 3s


000-input.conf: |-
  input {
    http {
      port => "8080"
    }
    beats {
      port => "5044"
    }
  }

500-filter.conf: |-
  filter {
    mutate {
      add_field => { "environment" => "Production" }
    }
  }

999-output.conf: |-
  output {
    opensearch {
      hosts => [ "https://observability-opensearch-data-az2-headless:9200", "https://observability-opensearch-data-az1-headless:9200" ]
      index  => "observability"
      user => "admin"
      password => "admin"
      ssl_certificate_verification => false
    }
  }
```

```yaml
filebeat.yml: |
  filebeat.inputs:
    - type: log
      enabled: true
      paths:
        - /tmp/server.log
      fields_under_root: true
      encoding: utf-8

  output.logstash:
    hosts: [ "observability-logstash:5044" ]
    loadbalance: true
```