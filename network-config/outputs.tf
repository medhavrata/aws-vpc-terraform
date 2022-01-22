output "vpc_id" {
  value = aws_vpc.first_vpc.id
}

output "public_subnets" {
  value = aws_subnet.public_subnet
}
