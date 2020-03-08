# Using Oracle Linux Virtualization Manager on GCP

This directories provides resources to install Oracle Linux Virtualization
Manager based on oVirt on top of GCP.

## Install Oracle Linux on GCP

GCP does not provide Oracle Linux templates. To work around this issue a quick
way to install it is to install a CentOS 7 VM and switch to Oracle Linux as
described in
[Switch your CentOS systems to Oracle Linux](https://linux.oracle.com/switch/centos/).

To proceed, install a CentOS and run the set of commands below as root:

```shell
curl -O https://linux.oracle.com/switch/centos2ol.sh
sh centos2ol.sh 
yum distro-sync
rm -f centos2ol.sh

yum repolist
yum install kernel-uek
reboot
```

## Using the gcloud CLI

Another important part of the work, once you've created an instance and stopped
it with a disk and Oracle Linux on it is to create an image with nested
virtualization; to proceed, connect to GCP, stop `ovirt-host1` and create an
image that has `enable-vmx` like below:

```shell
gcloud auth activate-service-account --key-file=./account.json
gcloud config set project diamond-268809
gcloud compute instances stop ovirt-host1

gcloud compute images create ovirt-host \
  --source-disk ovirt-host1 --source-disk-zone us-central1-a \
  --storage-location us-central1 --family=oracle-linux \
  --licenses "https://compute.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"

gcloud compute instances list
```

## Play with the API

Once you've configured Oracle Linux Virtualization Manager, you should be able
to play with the API. In order to proceed, check the API, for version 4.2, in
the [associated documentation](https://access.redhat.com/documentation/en-us/red_hat_virtualization/4.2/html/rest_api_guide/index)

Also, make sure:

- [ovirt-imageio-proxy is correctly configured](https://docs.oracle.com/en/virtualization/oracle-linux-virtualization-manager/getstart/storage-config.html#images-upload)
- 54323 is opened and the certificate authority associated with the domain is registered in the browser for XHR access


### Get the Certificate

The command below gets the certificatei from `curl`:

```shell
curl --output ca.crt -k \
  'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/services/pki-resource?resource=ca-certificate&format=X509-PEM-CA'
```

### Authenticate

Assuming your stored the ovirt-engine setup in `engine.conf` you can get the
password from the file and get a token with the set if command below:

```shell
export OLVMPASSWORD=$(grep adminPassword engine.conf | \
  cut -d':' -f2 | sed s/=/%3D/g | sed s/+/%2B/g | sed s/\//%2F/g)

curl -XPOST --cacert ./ca.crt \
  'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/sso/oauth/token' \
  -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' \
  -d "grant_type=password&scope=ovirt-app-api&username=admin%40internal&password=$OLVMPASSWORD"

export ACCESS_TOKEN=uch8BJ8AyW4mhqptnwpBSKo0WzqlFH8WZVUSSOAHQ6lwmJGdJMFriYbE_DFV6fEBmtnms1HAsDUWVsn9xob8rA

curl --cacert ./ca.crt \
  'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/api/domains' \
  -H 'Authorization: Bearer '$ACCESS_TOKEN
```

## Query Hosts

Once you have a token, getting the list of hosts should be as easy as the
command below:

```shell
curl --cacert $CA/ca.crt 'https://engine.us-central1-a.c.diamond-268809.internal/ovirt-engine/api/hosts/' \
   -H 'Authorization: Bearer '$ACCESS_TOKEN -H 'Accept: application/json' \
  | jq '.host | .[] | {id, name}'
```

> Note: to interact with oVirt engine, you would very likely prefer to use
> `ovirt-engine-sdk-python`. It is already installed on the oVirt Hosts.

