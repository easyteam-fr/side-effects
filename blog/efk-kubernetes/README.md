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
