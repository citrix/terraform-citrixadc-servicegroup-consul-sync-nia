# Additional configuration to be set after CTS has run and created
# the appropriate servicegroups

# Create lb vserver
resource "citrixadc_lbvserver" "consul_counting_lbvserver" {
  ipv46       = "10.10.10.33"
  name        = "consul_counting_lbvserver"
  port        = 80
  servicetype = "HTTP"
}

# Bind to servicegroup
resource "citrixadc_lbvserver_servicegroup_binding" "consul_servicegroup_bind" {
  name = citrixadc_lbvserver.consul_counting_lbvserver.name
  servicegroupname = "consul_counting_servicegroup"
}
