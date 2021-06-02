terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
    }
  }
}

# Create a servicegroup per service name
resource "citrixadc_servicegroup" "consul_servicegroup" {
  for_each = local.consul_services

  servicegroupname = "consul_${each.key}_servicegroup"
  servicetype      = "HTTP"
}

# Create a servicegroup member binding for each service instance
# servicegroupname must be the same as in the corresponding servicegroup definition
resource "citrixadc_servicegroup_servicegroupmember_binding" "consul_servicegroup_binding" {
  for_each = var.services

  servicegroupname = "consul_${each.value.name}_servicegroup"
  ip = each.value.address
  port = each.value.port

  depends_on = [citrixadc_servicegroup.consul_servicegroup]
}

locals {
  consul_service_ids = transpose({
    for id, s in var.services : id => [s.name]
  })

  # Group services by name
  consul_services = {
    for name, ids in local.consul_service_ids :
    name => [for id in ids : var.services[id]]
  }
}
