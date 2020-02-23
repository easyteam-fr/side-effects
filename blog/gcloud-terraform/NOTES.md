# Oracle Linux Virtualization Manager and GCP

This directories provides resources to install oVirt on top of GCP. To
check the API, for version 4.2, check the
[associated documentation](https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.2/html/rest_api_guide/index)

# Also

You should make sure
- ovirt-imageio-proxy is correctly configured as documented in https://docs.oracle.com/en/virtualization/oracle-linux-virtualization-manager/getstart/storage-config.html#images-upload
  make sure you push the certificate
- 54323 is opened and the certificate authority associated with the domain is registered in the browser for XHR access


## Get the Certificate

curl --output ca.crt -k 'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/services/pki-resource?resource=ca-certificate&format=X509-PEM-CA'

## Authenticate

export OLVMPASSWORD=$(grep adminPassword engine.conf |  cut -d':' -f2 | sed s/=/%3D/g | sed s/+/%2B/g | sed s/\//%2F/g)

curl -XPOST --cacert ./ca.crt 'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/sso/oauth/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' \
  -d "grant_type=password&scope=ovirt-app-api&username=admin%40internal&password=$OLVMPASSWORD"

export ACCESS_TOKEN=uch8BJ8AyW4mhqptnwpBSKo0WzqlFH8WZVUSSOAHQ6lwmJGdJMFriYbE_DFV6fEBmtnms1HAsDUWVsn9xob8rA

curl --cacert ./ca.crt 'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/api/domains' \
  -H 'Authorization: Bearer '$ACCESS_TOKEN


## Query Hosts

curl --cacert $CA/ca.crt 'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/api/hosts/' \
   -H 'Authorization: Bearer '$ACCESS_TOKEN -H 'Accept: application/json' \
  | jq '.host | .[] | {id, name}'

