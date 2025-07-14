terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Create VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.vpc_name}-${var.environment}-vpc"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = toset(var.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, index(var.azs, each.key) + 10)
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-${var.environment}-pub-${each.key}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = toset(var.azs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.cidr_block, 8, index(var.azs, each.key))
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.vpc_name}-${var.environment}-pri-${each.key}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-${var.environment}-igw"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.vpc_name}-${var.environment}-pub-rt"
  }
}

# Associate Public Subnets with Public RT
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  domain   = "vpc"

  tags = {
    Name = "${var.vpc_name}-${var.environment}-nat-eip-${each.key}"
  }
}

# NAT Gateways in Public Subnets
resource "aws_nat_gateway" "this" {
  for_each      = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = {
    Name = "${var.vpc_name}-${var.environment}-natgw-${each.key}"
  }

  depends_on = [aws_internet_gateway.this]
}

# Private Route Tables (one per AZ)
resource "aws_route_table" "private" {
  for_each = aws_subnet.private

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = {
    Name = "${var.vpc_name}-${var.environment}-pri-rt-${each.key}"
  }
}

# Associate Private Subnets with their RT
resource "aws_route_table_association" "private" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}


