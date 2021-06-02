## Terraform citrixadc servicegroup Consul sync module for Network Infrastructure Automation (NIA)

This Terraform module allows users to automatically create, update and delete Service groups in Citrix ADC that
are synced with the [Consul Terraform Sync](https://www.consul.io/docs/nia) framework.

## Feature

The module will create a servicegroup for each Service and then bind to it servicemembers according to
the number of instances for each service as sourced from the [Consul service discovery](https://www.consul.io/).

This will result in servicegroups being in sync with the services sourced from Consul.
Adding, deleting or modyfing services in Consul will result in servicegroups and its servicemembers
reflecting these changes.

The configuration offers only the backend portion of the configuration for the Citrix ADC.

The user is expected to create frontend vservers and bind them to the servicegroups created in order to
have a functional Load Balancing or Content Switching setup.

## Requirements

### Ecosystem Requirements

| Ecosystem | Version |
|-----------|---------|
| [consul](https://www.consul.io/downloads) | >= 1.7 |
| [consul-terraform-sync](https://www.consul.io/docs/nia) | >= 0.1.0 |
| [terraform](https://www.terraform.io) | >= 0.13 |

### Terraform Providers

| Name | Version |
|------|---------|
| citrixadc | >= 1.0.0 |

## Setup



1. The user is expected to have the Consul service up and running and reachable through an ip address.
2. The Consul Terraform Sync binary is installed
3. A configuration file for Consul Terraform Sync is present
4. This terraform module is present

## Usage

To use this module make sure the setup is complete as described in the previous section.

You need to edit the Consul Terraform Sync configuration file to match your needs.

Set the consul address to the appropriate value.
In the example we are running Consul on the local machine with Docker.

For each service you want to register create a service block as shown in the example.

Declare the terraform citrixadc provider as shown.

Make sure to give the correct authentication credentials in the terraform\_provider block
as shown in the example configuration.

Lastly the task block is where all is tied together.
Of note is the `source` attribute in this block.
It must point to the filepath of this terraform module.

Having completed all the previous steps running the actual `consul-terraform-sync` binary is the
last step.

Run like so
```bash
consul-terraform-sync -config-file config.hcl
```

After that the process will remain running and any changes to the Consul catalog
that refer to the services being synced will be reflected on the ADC configuration.

**User Config for Consul Terraform Sync**

example.hcl
```hcl
consul {
  address = "localhost:8500"
}

service {
  name = "counting"
  datacenter = "dc1"
  description = "Sample counting service for demo purposes"
}

service {
  name = "adc_svc"
  datacenter = "dc1"
  description = "Sample service for demo purposes"
}

task {
  name = "adc_task"
  description = "Sync services to ADC"
  enabled = true,
  providers = ["citrixadc"]
  services = ["counting", "adc_svc"]
  source = "terraform-citrixadc-servicegroup-consul-sync-nia"
  variable_files = []
}

driver "terraform" {
  log = true

  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}

terraform_provider "citrixadc" {
  endpoint = "https://10.0.1.1"
  username = "nsroot"
  password = "verysecret1234"
  insecure_skip_verify = true
}
```
## Extending the module

The module uses a small subset of the services input variables attributes.
Namely the name, address and port to create servicegroups and servicegroup members.

The user may wish to extend the module to fit his needs.

For example you could have the frontend Virtual Servers created with dynamic blocks
using the `for_each` construct of HCL.

Or one could use the extra fields in the services input variable to dynamically
setup other attributes of the servicegroup or servicegroup members.

To get an idea of what is available you can look into the `variables.tf` file
where the definition of the `services` variable is located.

Also of note is the fact that after the run of the `consul-terraform-sync`
command a directory will be created which will contain all the input variables'
values.

The path will be `sync-tasks/<task_name>` and you can view the `terraform.tfvars` file to view
what the actual values are.

A sample of what this looks like is shown below
```hcl
services = {
  "adc_svc_1.client-1.dc1" : {
    id              = "adc_svc_1"
    name            = "adc_svc"
    kind            = ""
    address         = "172.17.0.6"
    port            = 9002
    meta            = {}
    tags            = ["go"]
    namespace       = null
    status          = "passing"
    node            = "client-1"
    node_id         = "cddb4e58-0d1e-8a75-a6d6-c50bec5b98b0"
    node_address    = "172.17.0.3"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan      = "172.17.0.3"
      lan_ipv4 = "172.17.0.3"
      wan      = "172.17.0.3"
      wan_ipv4 = "172.17.0.3"
    }
    node_meta = {
      consul-network-segment = ""
    }
    cts_user_defined_meta = {}
  },
  "counting1.client-1.dc1" : {
    id              = "counting1"
    name            = "counting"
    kind            = ""
    address         = "172.17.0.4"
    port            = 9001
    meta            = {}
    tags            = ["go"]
    namespace       = null
    status          = "passing"
    node            = "client-1"
    node_id         = "cddb4e58-0d1e-8a75-a6d6-c50bec5b98b0"
    node_address    = "172.17.0.3"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan      = "172.17.0.3"
      lan_ipv4 = "172.17.0.3"
      wan      = "172.17.0.3"
      wan_ipv4 = "172.17.0.3"
    }
    node_meta = {
      consul-network-segment = ""
    }
    cts_user_defined_meta = {}
  },
  "counting2.client-1.dc1" : {
    id              = "counting2"
    name            = "counting"
    kind            = ""
    address         = "172.17.0.5"
    port            = 9002
    meta            = {}
    tags            = ["go"]
    namespace       = null
    status          = "passing"
    node            = "client-1"
    node_id         = "cddb4e58-0d1e-8a75-a6d6-c50bec5b98b0"
    node_address    = "172.17.0.3"
    node_datacenter = "dc1"
    node_tagged_addresses = {
      lan      = "172.17.0.3"
      lan_ipv4 = "172.17.0.3"
      wan      = "172.17.0.3"
      wan_ipv4 = "172.17.0.3"
    }
    node_meta = {
      consul-network-segment = ""
    }
    cts_user_defined_meta = {}
  }
}
```
