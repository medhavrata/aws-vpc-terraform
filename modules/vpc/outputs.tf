output "vpc_id" {
  value = aws_vpc.first_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet
}

output "private_subnets" {
  value = aws_subnet.private_subnet
}

output "vpc_cidr_blocks" {
  value = aws_vpc.first_vpc.cidr_block
}
