#!/bin/bash
#######################################################
if [ -n "$1" ]; then
  NAMESPACE=$1
else
  NAMESPACE="openshift-infra"
fi

if ! oc whoami 2>/dev/null; then
  echo "User not login"
exit
fi

check_project="$(oc get project $NAMESPACE 2>/dev/null | grep Active  )"

if [ -z "$check_project" ]
then
  oc new-project $NAMESPACE
  NamespaceApply="yes"
else
  echo -n "Project " $NAMESPACE " exists. Continue? y-yes/n-no "
  read confirm

  if [ "$confirm" != "y" ]
  then
    echo "Input <script name> <namespase>"
    NamespaceApply="no"
  else
    NamespaceApply="yes"
  fi

fi

datasource_name='prometheus'
#NAMESPACE='kube-system'
sa_reader='prometheus'
graph_granularity='1m'
#yaml='grafana.yaml'
protocol="https://"

if [ $NamespaceApply == "yes" ]
then
oc project $NAMESPACE
oc process -f monitoring/prometheus.yaml -p NAMESPACE=$NAMESPACE | oc apply -f - -n $NAMESPACE
oc process -f monitoring/grafana.yaml -p NAMESPACE=$NAMESPACE | oc apply -f - -n $NAMESPACE
oc process -f monitoring/metrics-server.yaml | oc apply -f - -n kube-system
fi
oc rollout status deployment/grafana
oc adm policy add-role-to-user view -z grafana -n "${NAMESPACE}"

payload="$( mktemp )"
cat <<EOF >"${payload}"
{
"name": "${datasource_name}",
"type": "prometheus",
"typeLogoUrl": "",
"access": "proxy",
"url": "https://$( oc get route prometheus -n "${NAMESPACE}" -o jsonpath='{.spec.host}' )",
"basicAuth": false,
"withCredentials": false,
"jsonData": {
    "tlsSkipVerify":true,
    "httpHeaderName1":"Authorization"
},
"secureJsonData": {
    "httpHeaderValue1":"Bearer $( oc sa get-token "${sa_reader}" -n "${NAMESPACE}" )"
}
}
EOF


# setup grafana data source
grafana_host="${protocol}$( oc get route grafana -o jsonpath='{.spec.host}' )"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/datasources" -X POST -d "@${payload}"

# # deploy openshift dashboard
dashboard_file="./monitoring/node-exporter-dashboard.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@${dashboard_file}"
dashboard_file_docker="./monitoring/docker_containers.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@${dashboard_file_docker}"
dashboard_file_docker_1="./monitoring/docker_host.json"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@${dashboard_file_docker_1}"
#dashboard_file_kubernetes_pod="./monitoring/monitor_services.json"
#curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@${dashboard_file_kubernetes_pod}"
# ((node_exporter)) && node::exporter || echo "skip node exporter"

# exit 0
