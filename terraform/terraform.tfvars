aws_region   = "us-east-2"
project_name = "aws-ha-secure-webapp"

vpc_cidr = "10.0.0.0/16"

availability_zones = [
  "us-east-2a",
  "us-east-2b"
]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_app_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

private_db_subnet_cidrs = [
  "10.0.21.0/24",
  "10.0.22.0/24"
]
