module "vpc" {
  source = "../modules/vpc"

  name          = "lab"
  cidr_block    = "10.20.0.0/16"
  ingress_ports = var.ingress_ports

  subnets = {
    public-a  = { az = "us-east-1a", public = true, netnum = 1 }
    public-b  = { az = "us-east-1b", public = true, netnum = 2 }
    private-a = { az = "us-east-1a", public = false, netnum = 11 }
    private-b = { az = "us-east-1b", public = false, netnum = 12 }
  }
}
