log_level = "INFO"
port = 8558

buffer_period {
  enabled = true
  min = "5s"
  max = "20s"
}

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
