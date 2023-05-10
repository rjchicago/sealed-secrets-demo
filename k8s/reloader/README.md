# Reloader

* [Github](https://github.com/stakater/Reloader)
* [Helm](https://artifacthub.io/packages/helm/stakater/reloader)

``` yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example
  annotations:
    reloader.stakater.com/auto: "true"
spec:
  ...
```
