# Terraform Azure Setup


## Overview

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
* One file per template
* Meaningful file names
* Use variables - nothing is hard-coded in the templates
* PowerShell using https://shell.azure.com
* Document step-by-step setup to run the Terraform on a brand new on Azure Shell environment

## Format

https://github.com/vkhazin/multicloud-courseware/blob/master/content/course-intro/lab-jumpcloud.md