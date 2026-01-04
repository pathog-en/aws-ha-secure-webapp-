#############################################
# main.tf — Network foundation (no NAT yet)
# VPC + IGW + Public/Private Subnets + Routes
#############################################

locals {
  project_name = "aws-ha-secure-webapp"
}

#####################
# VPC
#####################
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.project_name}-vpc"
  }
}

#####################
# Internet Gateway
#####################
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project_name}-igw"
  }
}

#####################
# Subnets
#####################

# Public subnets (ALB / NAT will live here later)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.project_name}-public-${count.index + 1}"
    Tier = "public"
  }
}

# Private app subnets (compute will live here later)
resource "aws_subnet" "private_app" {
  count             = length(var.private_app_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_app_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${local.project_name}-private-app-${count.index + 1}"
    Tier = "private-app"
  }
}

# Private DB subnets (RDS will live here later)
resource "aws_subnet" "private_db" {
  count             = length(var.private_db_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_db_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${local.project_name}-private-db-${count.index + 1}"
    Tier = "private-db"
  }
}

#####################
# Route Tables
#####################

# Public route table: routes 0.0.0.0/0 to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project_name}-rt-public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route table for APP subnets (no default internet route yet)
resource "aws_route_table" "private_app" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project_name}-rt-private-app"
  }
}

# Associate private app subnets with private app route table
resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private_app.id
}

# Private route table for DB subnets (no default internet route)
resource "aws_route_table" "private_db" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${local.project_name}-rt-private-db"
  }
}

# Associate private db subnets with private db route table
resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private_db.id
}

#############################################
# Notes:
# - NAT Gateway is intentionally NOT included
#   to avoid cost until you're ready.
# - Next step is NAT + private routes for egress.
#############################################

resource "aws_vpc" "sanity_check" {
  cidr_block = "10.250.0.0/16"
  tags = { Name = "tf-sanity-check" }
}







