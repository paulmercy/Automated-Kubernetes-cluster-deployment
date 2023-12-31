
# kind-cluster
Create local Kubernetes clusters using Docker container "nodes" with [kind](https://kind.sigs.k8s.io/)


## Requirements

* [Docker](https://docs.docker.com/engine/install/)
* [kind](https://kind.sigs.k8s.io/docs/user/quick-start#installation)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm](https://helm.sh/docs/intro/install/)
* [curl](https://help.ubidots.com/en/articles/2165289-learn-how-to-install-run-curl-on-windows-macosx-linux)
* [jq](https://github.com/stedolan/jq/wiki/Installation)
* [base64](https://command-not-found.com/base64)

## Help

```bash
make help
```

```text
help                               - List available tasks
install-all                        - Install all (kind k8s cluster, Nginx ingress, MetaLB, demo workloads)
install-all-no-demo-workloads      - Install all (kind k8s cluster, Nginx ingress, MetaLB)
create-cluster                     - Create k8s cluster
export-cert                        - Export k8s keys(client) and certificates(client, cluster CA)
k8s-dashboard                      - Install k8s dashboard
nginx-ingress                      - Install Nginx ingress
metallb                            - Install MetalLB load balancer
deploy-app-nginx-ingress-localhost - Deploy httpd web server and create an ingress rule for a localhost (http://demo.localdev.me:80/), Patch ingress-nginx-controller service type -> LoadBlancer
deploy-app-helloweb                - Deploy helloweb
deploy-app-golang-hello-world-web  - Deploy golang-hello-world-web app
deploy-app-foo-bar-service         - Deploy foo-bar-service app
ingress-rule                       - Deploy ingress rule
Check-deployment-health            - check the health status of Deployment and resources assosiated with it 
delete-cluster                     - Delete K8s cluste
```

## Install all (kind k8s cluster, Nginx ingress, MetaLB, demo workloads)


```bash
./scripts/kind-install-all.sh
```

Or you can install each component individually

## Create k8s cluster


```bash
./scripts/kind-create.sh
```

## Export k8s keys(client) and certificates(client, cluster CA)


```bash
./scripts/kind-create.sh
```

Script creates:
- client.key
- client.crt
- client.pfx
- cluster-ca.crt

## Install k8s dashboard

Install k8s dashboard


```bash
./scripts/kind-add-dashboard.sh
```

Script creates file with admin-user token
- dashboard-admin-token.txt

## Launch k8s Dashboard

In terminal


```bash
# kill kubectl proxy if already running
pkill -9 -f "kubectl proxy"
# start new kubectl proxy
kubectl proxy –address=’0.0.0.0′ –accept-hosts=’^*$’ &
# copy admin-user token to the clipboard
cat ./dashboard-admin-token.txt | xclip -i
# open dashboard
xdg-open "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/" &
```

In Dashboard UI select "Token' and `Ctrl+V` 

## Install Nginx ingress


```bash
./scripts/kind-add-ingress-nginx.sh
```

## Install MetalLB load balancer


```bash
./scripts/kind-add-metallb.sh
```

## Deploy demo workloads

### Deploy httpd web server and create an ingress rule for a localhost `http://demo.localdev.me:80/`


```bash
./scripts/kind-deploy-app-nginx-ingress-localhost.sh
```

### Deploy helloweb


```bash
./scripts/kind-deploy-app-helloweb.sh
```

### Deploy golang-hello-world-web


```bash
./scripts/kind-deploy-app-golang-hello-world-web.sh
```

### Deploy foo-bar-service


```bash
./scripts/kind-deploy-app-foo-bar-service.sh
```

### Deploy Prometheus

Add prometheus and stable repo to local helm repository
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add stable https://charts.helm.sh/stable
helm repo update
```

Create namespace monitoring to deploy all services in that namespace
```bash
kubectl create namespace monitoring
```

Install kube-prometheus stack
```bash
helm template kind-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring \
--set prometheus.service.nodePort=30000 \
--set prometheus.service.type=LoadBalancer \
--set grafana.service.nodePort=31000 \
--set grafana.service.type=LoadBalancer \
--set alertmanager.service.nodePort=32000 \
--set alertmanager.service.type=LoadBalancer \
--set prometheus-node-exporter.service.nodePort=32001 \
--set prometheus-node-exporter.service.type=LoadBalancer \
> ./k8s/prometheus.yaml

kubectl apply -f ./k8s/prometheus.yaml
kubectl --namespace monitoring get pods -l release=kind-prometheus
```

Kube-prometheus-stack-Grafana
```bash
    ./scripts/kind-add-kube-prometheus-stack.sh
```

Delete kube-prometheus stack
```bash
kubectl delete -f ./k8s/prometheus.yaml
```

## Delete k8s cluster


```bash
./scripts/kind-delete.sh
```