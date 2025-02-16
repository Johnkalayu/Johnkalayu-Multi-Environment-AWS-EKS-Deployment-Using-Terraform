module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = var.vpc_name
    cidr = var.vpc_cidr


    azs             = var.availability_zones
    public_subnet_names = var.public_subnet_name
    public_subnets = var.public_subnet_cidr

    enable_nat_gateway = false
    single_nat_gateway = false
    enable_dns_support = true
    enable_dns_hostnames = true

  tags = {
    ENVIRONMENT = var.environment
  }
}