# Kubeseal-WebGUI

* Docs: <https://github.com/Jaydee94/kubeseal-webgui>
* Helm: <https://artifacthub.io/packages/helm/kubeseal-webgui/kubeseal-webgui>

## API

It is possible to curl the `kubeseal-webgui` API to obtain the sealed secret.

### Example

``` sh
curl 'http://kubeseal.localhost:8080/secrets' \
  -H 'Content-Type: application/json' \
  -d '{"secret": "test","namespace": "demo","scope": "strict","secrets": [{"key": "FOO","value": "QkFSCg=="}]}'
```

Notes:

* this is per cluster
* value must be base64 encoded
