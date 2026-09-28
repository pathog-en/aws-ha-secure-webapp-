#############################################
# VPC Endpoints
# Private access to required AWS services
#############################################

# S3 Gateway Endpoint
# EKS nodes require access to S3 for ECR image layers.
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_app.id
  ]

  tags = {
    Name    = "${local.name}-s3-endpoint"
    Project = local.name
  }
}

#############################################
# Interface Endpoint Security Group
#############################################

resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name}-vpc-endpoints-sg"
  description = "Allow HTTPS from private application subnets to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name    = "${local.name}-vpc-endpoints-sg"
    Project = local.name
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  for_each = toset(var.private_app_subnet_cidrs)

  security_group_id = aws_security_group.vpc_endpoints.id
  cidr_ipv4         = each.value
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  description = "HTTPS from private application subnet"
}

#############################################
# ECR Interface Endpoints
#############################################

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name    = "${local.name}-ecr-api-endpoint"
    Project = local.name
  }
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name    = "${local.name}-ecr-dkr-endpoint"
    Project = local.name
  }
}
#############################################
# EC2 Interface Endpoint
# Required by EKS networking components
#############################################

resource "aws_vpc_endpoint" "ec2" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name    = "${local.name}-ec2-endpoint"
    Project = local.name
  }
}

#############################################
# Elastic Load Balancing Interface Endpoint
# Required by AWS Load Balancer Controller
#############################################

resource "aws_vpc_endpoint" "elasticloadbalancing" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name    = "${local.name}-elb-endpoint"
    Project = local.name
  }
}

#############################################
# Secrets Manager Interface Endpoint
#############################################

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name    = "${local.name}-secretsmanager-endpoint"
    Project = local.name
  }
}

#############################################
# EKS Auth Interface Endpoint
# Required for EKS Pod Identity without NAT
#############################################

resource "aws_vpc_endpoint" "eks_auth" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.eks-auth"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = aws_subnet.private_app[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  tags = {
    Name    = "${local.name}-eks-auth-endpoint"
    Project = local.name
  }
}