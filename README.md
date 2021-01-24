# Knative Python Echo Function for Arm64

Simple Python function with `Flask` REST API running in Knative to echo
[CloudEvents](https://github.com/cloudevents/sdk-python). This sample borrows from [Michael Gasch](https://twitter.com/embano1) repo [https://github.com/embano1/kn-echo](https://github.com/embano1/kn-echo) and creates an `arm64` container image using buildx.


> **Note:** CloudEvents using structured or binary mode are supported.

# Deployment (Knative)

**Note:** The following steps assume a working Knative environment using a `rabbit`
broker. The Knative `service` and `trigger` will be installed in the `default` Kubernetes namespace, assuming that the broker is also available there.

```bash
# create the service
kn service create kn-echo --port 8080 --image lamw/kn-python-echo:latest

# create the trigger
cat > trigger.yaml <<EOF
apiVersion: eventing.knative.dev/v1
kind: Trigger
metadata:
  name: veba-echo-trigger
spec:
  broker: rabbit
  subscriber:
    ref:
      apiVersion: serving.knative.dev/v1
      kind: Service
      name: kn-echo
EOF
kubectl apply -f trigger.yaml
```

# Build with `Docker`

- Requirements:
  - Docker 20.10+

```bash
docker buildx create --use --name mybuilder
docker buildx inspect --bootstrap
docker buildx build --platform linux/arm64/v8 --tag lamw/kn-python-echo:latest --push .
```

## Verify the image works by executing it locally:

```bash
docker run -e PORT=8080 -it --rm -p 8080:8080 lamw/kn-python-echo:latest

# now in a separate window or use -d in the docker cmd above to detach
curl -i localhost:8080
HTTP/1.0 200 OK
Content-Type: application/json
Content-Length: 80
Server: Werkzeug/1.0.1 Python/3.9.1
Date: Sun, 24 Jan 2021 23:01:57 GMT

{
  "message": "POST to this endpoint to echo cloud events",
  "status": 200
}
```