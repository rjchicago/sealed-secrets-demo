# Sealed Secrets Demo

## Checklist

### Basics

* Get a local cluster with [K3D](#k3d).
* Verify your current [context](#kubeconfig).
* Install [SealedSecrets](#sealed-secrets).
* Install [kubeseal](#kubeseal).

### Bonus

* Install [Traefik](#traefik) for ingress.
* Install [kubeseal-webgui](#kubeseal-webgui)

### K3D

> [k3d](https://k3d.io/) is a lightweight wrapper to run [k3s](https://github.com/k3s-io/k3s) (Rancher Lab’s minimal Kubernetes distribution) in docker.

* [Installation](https://k3d.io/v5.4.9/#other-installers)
* [Documentation](https://k3d.io/v5.4.9/usage/commands/k3d_cluster_create/)

Create a cluster with 1 controller and 3 workers:

``` sh
k3d cluster create local \
    -s 1 -a 3 \
    --k3s-arg "--disable=traefik@server:*" \
    --k3s-arg "--disable=servicelb@server:*" \
    --k3s-arg "--node-taint=node-role.kubernetes.io/master:NoSchedule@server:*"

# verify
kubectl get nodes
```

When done, you may simply delete the cluster via k3d:

``` sh
k3d cluster delete local
```

### kubeconfig

Ensure you're using a local context for testing...

``` sh
# current context
kubectl config current-context

# list contexts
kubectl config get-contexts

# use context
kubectl config use-context ${CONTEXT}
```

### Sealed-Secrets

``` sh
NAMESPACE=sealed-secrets

# install
helm upgrade --install \
    --create-namespace \
    -n $NAMESPACE \
    --dependency-update \
    -f ./k8s/$NAMESPACE/clusters/${CLUSTER:-local}/values.yaml \
    $NAMESPACE \
    ./k8s/$NAMESPACE

# check
kubectl get all -n $NAMESPACE
```

### Kubeseal

* [Installation](https://github.com/bitnami-labs/sealed-secrets#kubeseal)

``` sh
brew install kubeseal
```

#### Kubeseal Demo

``` sh
# create sealed-secret
echo "
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
data:
  password: YmFy
  username: Zm9v
" \
| kubeseal \
--controller-namespace sealed-secrets \
--controller-name sealed-secrets \
--format yaml \
| kubectl apply -f -

# get sealedsecret
kubectl get sealedsecret my-secret -o yaml

# get secret
kubectl get secret my-secret -o yaml
```

### Traefik

``` sh
NAMESPACE=traefik

# install
helm upgrade --install \
    --create-namespace \
    -n $NAMESPACE \
    --dependency-update \
    -f ./k8s/$NAMESPACE/clusters/${CLUSTER:-local}/values.yaml \
    $NAMESPACE \
    ./k8s/$NAMESPACE

# check
kubectl get all -n $NAMESPACE
```

Once Traefik is running, you may port-forward to the Traefik service:

``` sh
( exec -a pf8080 kubectl port-forward svc/traefik -n traefik 8080:80 > /dev/null ) &
```

#### Traefik Dashboard

* <http://traefik.localhost:8080/>

### Kubeseal WebGui

``` sh
NAMESPACE=kubeseal-webgui

# install
helm upgrade --install \
    --create-namespace \
    -n $NAMESPACE \
    --dependency-update \
    -f ./k8s/$NAMESPACE/clusters/${CLUSTER:-local}/values.yaml \
    $NAMESPACE \
    ./k8s/$NAMESPACE

# check
kubectl get all -n $NAMESPACE
```

Open:

* <http://kubeseal.localhost:8080/>

Enjoy!

### Demo

``` sh
NAMESPACE=demo

# install
helm upgrade --install \
    --create-namespace \
    -n $NAMESPACE \
    --dependency-update \
    -f ./k8s/$NAMESPACE/clusters/${CLUSTER:-local}/values.yaml \
    $NAMESPACE \
    ./k8s/$NAMESPACE

# check
kubectl get all -n $NAMESPACE
```

Next, we'll create a sealed secret in our namespace:

``` sh
curl 'http://kubeseal.localhost:8080/secrets' \
  -H 'Content-Type: application/json' \
  -d '{"secret": "secret","namespace": "demo","scope": "strict","secrets": [{"key": "FOO","value": "QkFS"}]}' | jq '.[0].value' | pbcopy # sealedsecret value will be copied to clipboard
```

open [./k8s/demo/clusters/local/values.yaml](./k8s/demo/clusters/local/values.yaml) and add the following...

``` yaml
sealedsecrets:
  secret:
    FOO: <paste sealedsecret value>
```
