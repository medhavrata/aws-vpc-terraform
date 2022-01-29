output "vpc_id" {
  value = module.create_vpc.vpc_id
}

output "public_subnets" {
  value = module.create_vpc.public_subnets
}

output "private_subnets" {
  value = module.create_vpc.private_subnets
}

output "vpc_cidr_blocks" {
  value = module.create_vpc.vpc_cidr_blocks
}
