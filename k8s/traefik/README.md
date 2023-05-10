# Traefik

> [Traefik](https://traefik.io/) is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease.

* [Documentation](https://doc.traefik.io/traefik/)
* [Helm Chart](https://artifacthub.io/packages/helm/traefik/traefik)

## Versions

### Traefik Version

The Traefik version is managed via `appVersion` in [Chart.yaml](Chart.yaml).

Be sure to check [release notes](https://github.com/traefik/traefik/releases) when upgrading Traefik.

### Helm Chart Version

The Traefik Helm Chart version is managed in the `dependency` section of [Chart.yaml](Chart.yaml).

When the chart version is updated, the following command must be ran to obtain the new chart (.lock & .tgz):

``` sh
helm dependency build .
```

If there are new default values, [download](https://artifacthub.io/packages/helm/traefik/traefik?modal=values) and replace `values.yaml` in [.defaults](./.defaults).

## Testing Locally

### Checklist

* Ensure you are using the correct [context](#kubeconfig).
* Get a local test cluster with [K3D](#k3d).

### Commands

``` sh
# lint
helm lint -f clusters/${CLUSTER:-local}/values.yaml .

# template
helm template --debug -f clusters/${CLUSTER:-local}/values.yaml .

# create traefik namespace
kubectl create ns traefik -o yaml --dry-run=client | kubectl apply -f -

# debug/dry-run
helm upgrade --install --debug --dry-run -n traefik -f clusters/${CLUSTER:-local}/values.yaml traefik .
# NOTE: the above will fail if Traefik CRDs have not yet been applied. To apply the CRDs manually, run:
# kubectl apply -f https://raw.githubusercontent.com/traefik/traefik/v2.9/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml

# helm install/upgrade
helm upgrade --install -n traefik -f clusters/${CLUSTER:-local}/values.yaml traefik .
```

### Verify

``` sh
kubectl get all -n traefik
```

You should see similar output:

``` txt
NAME                READY   STATUS    RESTARTS   AGE
pod/traefik-r2kx4   1/1     Running   0          3m
pod/traefik-vr9dh   1/1     Running   0          3m
pod/traefik-k2s9v   1/1     Running   0          3m

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/traefik   ClusterIP   10.43.220.147   <none>        80/TCP,443/TCP   3m

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/traefik   3         3         3       3            3           <none>          3m
```

### Port Forward

In order to access locally, we need to configure a port-forward:

``` sh
( exec -a pf8080 kubectl port-forward svc/traefik -n traefik 8080:80 > /dev/null ) &
```

This can be later removed by calling:

``` sh
pkill pf8080
```

### URLs

* <http://traefik.localhost:8080/>
* <http://traefik.localhost:8080/ping>
* <http://traefik.localhost:8080/metrics>

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
