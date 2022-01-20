# Output Block
output "sub_id" {
  value = aws_subnet.public_subnet[0].id
}

output "vpc_id" {
  value = aws_vpc.first_vpc.id
}

output "vpc_cidr_block" {
  value = aws_vpc.first_vpc.cidr_block
}
