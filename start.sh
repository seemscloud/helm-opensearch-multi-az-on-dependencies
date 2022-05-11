PORT="9300"
ENDPOINT=observability-opensearch-master

read -d "" TO_EXEC <<EndOfMessage
/usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh \
-icl -nhnv -rev -h ${ENDPOINT} -p ${PORT} \
-cacert config/certs/admin-ca.crt.pem \
-cert config/certs/admin.crt.pem -key config/certs/admin.key.pem \
-cd plugins/opensearch-security/securityconfig
EndOfMessage

if [ "${HOSTNAME##*-}" == "0" ] ; then
  while true; do
    if timeout 3 /bin/bash -c "echo > /dev/tcp/${ENDPOINT}/${PORT}" ; then
      eval "${TO_EXEC}" && echo "Security plugin updated.." && break
    fi
    echo "Waiting for port.." && sleep 1
  done
fi