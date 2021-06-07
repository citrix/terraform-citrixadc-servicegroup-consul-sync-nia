terraform {
  required_providers {
    citrixadc = {
      source = "citrix/citrixadc"
      version = ">= 1.1.0"
    }
  }
}
provider "citrixadc" {
  endpoint = "http://localhost:8080"
}
