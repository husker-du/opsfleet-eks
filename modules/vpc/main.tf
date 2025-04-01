provider "aws" {
  region = var.region
}

module "vpc_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["vpc"]
}

module "public_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["public"]

  tags = merge(
    module.this.tags,
    {
      # Tag subnets to be used for external ELBs created by LoadBalancer services
      "kubernetes.io/role/elb" = 1
    }
  )
}

module "private_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["private"]

  tags = merge(
    module.this.tags,
    {
      # Tag subnets to be used for internal ELBs created by LoadBalancer services
      "kubernetes.io/role/internal-elb" = 1
      # Tags subnets for Karpenter auto-discovery
      "karpenter.sh/discovery" = var.cluster_name
    }
  )
}

module "intra_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["intra"]
}

data "aws_availability_zones" "available" {}

#########################################
# VPC
#########################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    module.vpc_context.tags,
    { Name = module.vpc_context.id }
  )
}

#########################################
# Private subnets
#########################################
resource "aws_subnet" "private" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    module.private_context.tags,
    {
      Tier = "Private"
      Name = "${module.private_context.id}-${local.azs[count.index]}"
    }
  )
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    module.vpc_context.tags,
    { Name = module.vpc_context.id }
  )
}

resource "aws_eip" "natgw" {
  domain = "vpc"
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    module.vpc_context.tags,
    { Name = module.private_context.id }
  )
}

resource "aws_route" "natgw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id

  depends_on = [aws_eip.natgw]
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

#########################################
# Public subnets
#########################################
resource "aws_subnet" "public" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    module.public_context.tags,
    {
      Tier = "Public"
      Name = "${module.public_context.id}-${local.azs[count.index]}"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    module.vpc_context.tags,
    { Name = module.public_context.id }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    module.vpc_context.tags,
    { Name = module.public_context.id }
  )
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#########################################
# Intra subnets (no internet access)
#########################################
resource "aws_subnet" "intra" {
  count             = length(local.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.intra_cidrs[count.index]
  availability_zone = local.azs[count.index]

  tags = merge(
    module.vpc_context.tags,
    {
      Tier = "Intra"
      Name = "${module.intra_context.id}-${local.azs[count.index]}"
    }
  )
}

resource "aws_route_table" "intra" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    module.vpc_context.tags,
    { Name = module.intra_context.id }
  )
}

resource "aws_route_table_association" "intra" {
  count          = length(aws_subnet.intra)
  subnet_id      = aws_subnet.intra[count.index].id
  route_table_id = aws_route_table.intra.id
}
