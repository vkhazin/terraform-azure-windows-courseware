# Terraform Azure Setup


## Requirements

* Create terraform templates to setup Azure
* One Virtual Network
* Internet Access
* One public subnet
* One private subnet
* One security group with RDP incoming port
* One Windows Server 2016 instance with dynamic public IP
* Disks: 
```
C: Os, assigned letter and size defined in variables
E: Empty, assigned letter and size defined in variables
F: Empty, assigned letter and size defined in variables
P: Os pagefile, assigned letter and size defined in variables
T: Empty, assigned letter and size defined in variables
```

## Discoveries

* Windows on Azures uses temporary storage for the pagefile instead of a dedicated drive
* Windows names drives in order, can be renamed, but maybe not worthwhile

## Deployments

* Login to https://shell.azure.com or install [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) and [Terraform](https://www.terraform.io/downloads.html) locally
* Clone the repository: `git clone https://vkhazin@bitbucket.org/vk-crs/terraform-azure-bto.git`
* Login to azure cli: `az login`
* Initialize providers: `terraform init`
* Validate configuration: `terraform validate`
* Preview changes: `terraform plan -var-file=./envs/azure-poc.tfvars`
* Create/Update an environment: `terraform apply -var-file=./envs/azure-poc.tfvars --auto-approve`
* Destroy the environment: `terraform destroy -var-file=./envs/azure-poc.tfvars --auto-approve`