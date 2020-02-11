# Using this demonstration

## Configuring the project

In order to use this configuration, you would have to configure it:

- Create a file named `variables.auto.tfvars` that contains:
  - `public_key` is the string of your private key usually in `~/.ssh/id_rsa.pub`
  - `profile` is a awscli profile that exists in your `~/.aws/credentials` file

```text
public_key = "ssh-rsa AAAA..."
profile = "default"
```

- Run `terraform init` to download the aws module

- check the configuration for `aws_instance.public`

```shell
terraform state show "aws_instance.public"
```

