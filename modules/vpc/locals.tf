locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.num_azs)

  vpc_prefix      = split("/", var.vpc_cidr)[1]
  private_newbits = [for k, v in local.azs : var.private_prefix - local.vpc_prefix]
  public_newbits  = [for k, v in local.azs : var.public_prefix - local.vpc_prefix]
  intra_newbits   = [for k, v in local.azs : var.intra_prefix - local.vpc_prefix]

  subnet_newbits = concat(local.private_newbits, local.public_newbits, local.intra_newbits)

  subnet_cidrs  = cidrsubnets(var.vpc_cidr, local.subnet_newbits...)
  private_cidrs = slice(local.subnet_cidrs, 0, length(local.azs))
  public_cidrs  = slice(local.subnet_cidrs, length(local.azs), length(local.azs) * 2)
  intra_cidrs   = slice(local.subnet_cidrs, length(local.azs) * 2, length(local.azs) * 3)
}