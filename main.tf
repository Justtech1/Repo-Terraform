# Configuring our network for Tenacity IT Group

# Create a VPC

resource "aws_vpc" "Tenacity-VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "Tenacity-VPC"
    Environment = "Tenacity"
  }
}

# Create 2 Public Subnets

resource "aws_subnet" "Prod-pub-sub1" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name        = "Prod-pub-sub1"
    Environment = "Tenacity"
  }
}

resource "aws_subnet" "Prod-pub-sub2" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name        = "Prod-pub-sub2"
    Environment = "Tenacity"
  }
}

# Create 2 Private Subnets

resource "aws_subnet" "Prod-priv-sub1" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name        = "Prod-priv-sub1"
    Environment = "Tenacity"
  }
}

resource "aws_subnet" "Prod-priv-sub2" {
  vpc_id     = aws_vpc.Tenacity-VPC.id
  cidr_block = "10.0.4.0/24"

  tags = {
    Name        = "Prod-priv-sub2"
    Environment = "Tenacity"
  }
}


# Create Public Route Table

resource "aws_route_table" "Prod-pub-route-table" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name        = "Prod-pub-route-table"
    Environment = "Tenacity"
  }
}

# Create Private Route Table

resource "aws_route_table" "Prod-priv-route-table" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name        = "Prod-priv-route-table"
    Environment = "Tenacity"
  }
}

# Associate Public subnet to the public Route table

resource "aws_route_table_association" "Pub-route1" {
  subnet_id      = aws_subnet.Prod-pub-sub1.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}

resource "aws_route_table_association" "Pub-route2" {
  subnet_id      = aws_subnet.Prod-pub-sub2.id
  route_table_id = aws_route_table.Prod-pub-route-table.id
}


# Associate Private subnet to the Private Route table

resource "aws_route_table_association" "Priv-route1" {
  subnet_id      = aws_subnet.Prod-priv-sub1.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}

resource "aws_route_table_association" "Priv-route2" {
  subnet_id      = aws_subnet.Prod-priv-sub2.id
  route_table_id = aws_route_table.Prod-priv-route-table.id
}


# Create Internet Gateway

resource "aws_internet_gateway" "Prod-igw" {
  vpc_id = aws_vpc.Tenacity-VPC.id

  tags = {
    Name        = "Prod-igw"
    Environment = "Tenacity"
  }
}

# Associate IGW with Public Route Table

resource "aws_route" "Prod-igw-association" {
  route_table_id         = aws_route_table.Prod-pub-route-table.id
  gateway_id             = aws_internet_gateway.Prod-igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Allocate Elastic IP address

resource "aws_eip" "eip_nat_gateway" {
  vpc      = true
}



# Create NAT Gateway

resource "aws_nat_gateway" "Prod-Nat-gateway" {
  allocation_id = aws_eip.eip_nat_gateway.id
  subnet_id     = aws_subnet.Prod-priv-sub1.id

  tags = {
    Name        = "Prod-Nat-gateway"
    Environment = "Tenacity"
  }
}


# Associate NAT Gateway with Private Route Table

resource "aws_route" "Prod-Nat-association" {
  route_table_id         = aws_route_table.Prod-priv-route-table.id
  gateway_id             = aws_nat_gateway.Prod-Nat-gateway.id
  destination_cidr_block = "0.0.0.0/0"
}
