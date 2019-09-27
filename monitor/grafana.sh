#!/bin/bash
#######################################################
datasource_name='prometheus'
prometheus_namespace='openshift-infra'
sa_reader='prometheus'
graph_granularity='1m'
yaml='grafana.yaml'
protocol="https://"


# set::oauth() {
# touch -a /etc/origin/master/htpasswd
# htpasswd /etc/origin/master/htpasswd grafana
# sed -ie 's|AllowAllPasswordIdentityProvider|HTPasswdPasswordIdentityProvider\n      file: /etc/origin/master/htpasswd|' /etc/origin/master/master-config.yaml
# oc adm policy add-cluster-role-to-user cluster-reader grafana
# systemctl restart atomic-openshift-master-api.service
# }

# # deploy node exporter
# node::exporter(){
# oc annotate ns kube-system openshift.io/node-selector= --overwrite
# sed -i.bak "s/Xs/${graph_granularity}/" "${dashboard_file}"
# sed -i.bak "s/\${DS_PR}/${datasource_name}/" "${dashboard_file}"
# curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@./node-exporter-full-dashboard.json"
# mv "${dashboard_file}.bak" "${dashboard_file}"
# }


oc project openshift-infra
oc process -f "${yaml}" |oc create -f -
oc rollout status deployment/grafana
oc adm policy add-role-to-user view -z grafana -n "${prometheus_namespace}"

payload="$( mktemp )"
cat <<EOF >"${payload}"
{
"name": "${datasource_name}",
"type": "prometheus",
"typeLogoUrl": "",
"access": "proxy",
"url": "https://$( oc get route prometheus -n "${prometheus_namespace}" -o jsonpath='{.spec.host}' )",
"basicAuth": false,
"withCredentials": false,
"jsonData": {
    "tlsSkipVerify":true,
    "httpHeaderName1":"Authorization"
},
"secureJsonData": {
    "httpHeaderValue1":"Bearer $( oc sa get-token "${sa_reader}" -n "${prometheus_namespace}" )"
}
}
EOF

# setup grafana data source
grafana_host="${protocol}$( oc get route grafana -o jsonpath='{.spec.host}' )"
curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/datasources" -X POST -d "@${payload}"

# # deploy openshift dashboard
# dashboard_file="./openshift-cluster-monitoring.json"
# sed -i.bak "s/Xs/${graph_granularity}/" "${dashboard_file}"
# sed -i.bak "s/\${DS_PR}/${datasource_name}/" "${dashboard_file}"
# curl --insecure -H "Content-Type: application/json" -u admin:admin "${grafana_host}/api/dashboards/db" -X POST -d "@${dashboard_file}"
# mv "${dashboard_file}.bak" "${dashboard_file}"

# ((node_exporter)) && node::exporter || echo "skip node exporter"

# exit 0