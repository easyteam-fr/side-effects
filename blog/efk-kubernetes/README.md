## Elastic/Kibana on the default bridge

This `docker-compose.yml` connect the `elasticsearch` and `kibana` images to
the default bridge so that in can be accessed by other services running on
the same instance. This is intented to use with a Kind cluster which, by
default also connect to that bridge.

A downside of this configuration is that the IP address is not managed in
spite of the `depends_on` property and, as a result, `kibana` does not
connect to `elasticsearch`. To work around that issue, run the following
command:

```shell
docker exec --user root kibana bash -c \
  "echo \"$(docker inspect -f {{.NetworkSettings.IPAddress}} elasticsearch)\" elasticsearch | tee -a /etc/hosts"
docker exec kibana cat /etc/hosts
```

What it does is get the IP from the `elasticsearch` container and inject
it to the `/etc/hosts` file in `kibana`. If you connect to
[localhost:5601](http://localhost:5601) you should connect to Kibana
with success.

## Connect a Kind Cluster to Elastic

If you create an Headless service without any selector and create some
endpoints that matches the service name and point to Elasticsearch, it
services in the cluster should be able to rely on it. That is the goal
of the `elasticsearch-svc.yaml`. To use it, perform the following steps:

- set the `IP_ADDRESS` variable with the Elastic IP address on the default
  bridge and create the headless service/endpoints in the `kube-system`
  namespace:

```shell
export IP_ADDRESS="$(docker inspect -f {{.NetworkSettings.IPAddress}} elasticsearch)"
envsubst < elasticsearch-svc.yaml | kubectl apply -f-
```

- test the you can access elastic by connecting to the debian pod you
  have created as part of the file and running `curl`:

```shell
kubectl exec -it debian -n kube-system -- bash
apt -y update
apt -y install curl
curl http://elasticsearch-logging:9200/
exit
```

- Once done, you can delete the debian pod:

```shell
kubectl delete pod debian -n kube-system
```

