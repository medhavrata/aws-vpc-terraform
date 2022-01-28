# Create a VPC
resource "aws_vpc" "first_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "first_vpc"
  }
}

# Create Public Subnets
locals {
  public_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
}

resource "aws_subnet" "public_subnet" {
  count = length(local.public_cidr)

  vpc_id     = aws_vpc.first_vpc.id
  cidr_block = local.public_cidr[count.index]
  availability_zone = data.aws_availability_zones.az_list.names[count.index]

  tags = {
    Name = "public${count.index}"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  count = length(local.private_cidr)

  vpc_id     = aws_vpc.first_vpc.id
  cidr_block = local.private_cidr[count.index]
  availability_zone = data.aws_availability_zones.az_list.names[count.index]

  tags = {
    Name = "private${count.index}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "first_vpc_igw" {
  vpc_id = aws_vpc.first_vpc.id

  tags = {
    Name = "first_vpc_igw"
  }
}

# Create two EIP that will be associated with NAT Gateway
resource "aws_eip" "nat_eip" {
  count = length(local.private_cidr)

  vpc = true

  depends_on = [
    aws_internet_gateway.first_vpc_igw
  ]
}

# Create two NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  count = length(local.private_cidr)

  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "nat_gw${count.index}"
  }

  depends_on = [
    aws_internet_gateway.first_vpc_igw
  ]
}

# Create public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.first_vpc_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Create private route table
resource "aws_route_table" "private_route_table" {
  count = length(local.private_cidr)

  vpc_id = aws_vpc.first_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name = "private_route_table${count.index}"
  }
}

# Route Table Association
resource "aws_route_table_association" "public_rt_association" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_rt_association" {
  count = length(local.private_cidr)

  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}
