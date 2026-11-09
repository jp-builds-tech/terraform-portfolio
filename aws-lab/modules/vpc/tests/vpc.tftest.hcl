mock_provider "aws" {}

variables {
  name = "lab"
  subnets = {
    public-a  = { az = "us-east-1a", public = true, netnum = 1 }
    private-a = { az = "us-east-1a", public = false, netnum = 11 }
  }
}

run "subnet_cidrs_come_from_netnum" {
  command = plan

  assert {
    condition     = aws_subnet.this["public-a"].cidr_block == "10.20.1.0/24"
    error_message = "public-a should be 10.20.1.0/24."
  }

  assert {
    condition     = aws_subnet.this["private-a"].cidr_block == "10.20.11.0/24"
    error_message = "private-a should be 10.20.11.0/24."
  }
}

run "only_public_subnets_are_routed" {
  command = plan

  assert {
    condition     = length(aws_route_table_association.public) == 1
    error_message = "Only the public subnet should get a route table association."
  }
}

run "rejects_invalid_cidr" {
  command = plan

  variables {
    cidr_block = "not-a-cidr"
  }

  expect_failures = [var.cidr_block]
}

run "rejects_bad_port" {
  command = plan

  variables {
    ingress_ports = [0]
  }

  expect_failures = [var.ingress_ports]
}
