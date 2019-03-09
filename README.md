# About

A cheap and cheerful, quick and nasty kubernetes cluster in Hetzner cloud, provisioned with terraform and ansible.

## Pre-requisites

- Linux/Mac OS (no reason you couldn't use Windows if you change the local-exec section, but the script snippet in there isn't currently platform agnostic)
- [Terraform](https://www.terraform.io/downloads.html)
- Ansible
- An SSH key pair
- An account with [Hetzner](https://www.hetzner.com/cloud)
- nc (used to check if ssh is available on the instances when provisioning)

## Getting started

Visit the [Hetzner Cloud Console](https://console.hetzner.cloud/projects) and create a new project.

In your new project, visit Access/API Tokens and generate an API token - keep this somewhere safe, this is all that is required to create/destroy services in your project so you don't want anybody else getting their hands on it.

Edit main.tf and change the local variables at the top (if required)

Run `terraform init` to pull missing providers

Run `terraform plan` to see what's going to happen followed by `terraform apply` to deploy

Or if you're feeling adventurous, just go straight for `terraform apply --auto-approve`

You will be prompted for your API key each time you run terraform commands, if you don't want this you can use a .tfvars file, env vars etc, e.g. with env vars:

```
TF_VAR_TOKEN=xxxxxxxx terraform plan
TF_VAR_TOKEN=xxxxxxxx terraform apply
```

Or

```
export TF_VAR_TOKEN=xxxxxxx
terraform plan
terraform apply
```

Once built, you can jump onto the master with `ssh root@$(terraform output Master)` and start monkeying around with kubectl, or pull the kube config to interact with it via kubectl/helm etc on your local machine with `scp root@$(terraform output Master):/root/.kube/config ~/.kube` etc. (note: that scp command as written will overwrite an existing config file in ~/.kube, modify accordingly if that's not what you want)

Note: firewalld is installed but stopped by default. It's up to you to decide which ports you need and finalise that end of things.

## Tearing it down

Run `terraform destroy` to scrap all the deployed services and the SSH key in Hetzner, then delete the project from the web interface.

