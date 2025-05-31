
#################################################
############## VPC + IGW CREATION ###############
#################################################

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.network_name}-VPC"
  }
}

# Create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.network_name}-igw"
  }
}



#################################################
################ SUBNET CREATION ################
#################################################

# Public subnet for AZ1
resource "aws_subnet" "pub_subnet_az1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.az1_pub_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.public_az1
  tags = {
    Name                                        = "public_subnet_az1"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

  }
}

# Public subnet for AZ2
resource "aws_subnet" "pub_subnet_az2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.az2_pub_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.public_az2
  tags = {
    Name                                        = "public_subnet_az2"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# Private subnet for AZ1
resource "aws_subnet" "priv_subnet_az1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.az1_priv_subnet_cidr
  availability_zone = var.private_az1

  tags = {
    Name                                        = "private_subnet_az1"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"

  }
}

# Private subnet for AZ2
resource "aws_subnet" "priv_subnet_az2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.az2_priv_subnet_cidr
  availability_zone = var.private_az2

  tags = {
    Name                                        = "private_subnet_az2"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}



#################################################
############# ROUTE TABLE CREATION ##############
#################################################

# Public route table
resource "aws_route_table" "pub_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.cidr_all
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_routetable"
  }
}

# Private route table for AZ1
resource "aws_route_table" "priv_route_table_az1" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.cidr_all
    nat_gateway_id = aws_nat_gateway.nat_az1.id
  }
  tags = {
    Name = "private_routetable_az1"
  }
}

# Private route table for AZ2
resource "aws_route_table" "priv_route_table_az2" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.cidr_all
    nat_gateway_id = aws_nat_gateway.nat_az2.id
  }
  tags = {
    Name = "private_routetable_az2"
  }
}



#################################################
####### ROUTE TABLES / SUBNET ASSOCIATION #######
#################################################

# Associate public route table with AZ1 public subnets
resource "aws_route_table_association" "public_route_table_az1" {
  subnet_id      = aws_subnet.pub_subnet_az1.id
  route_table_id = aws_route_table.pub_route_table.id
}

# Associate public route table with AZ2 public subnets
resource "aws_route_table_association" "public_route_table_az2" {
  subnet_id      = aws_subnet.pub_subnet_az2.id
  route_table_id = aws_route_table.pub_route_table.id
}

# Associate private route table with AZ1 private subnets
resource "aws_route_table_association" "private_route_table_az1" {
  subnet_id      = aws_subnet.priv_subnet_az1.id
  route_table_id = aws_route_table.priv_route_table_az1.id
}

# Associate private route table with AZ2 private subnets
resource "aws_route_table_association" "private_route_table_az2" {
  subnet_id      = aws_subnet.priv_subnet_az2.id
  route_table_id = aws_route_table.priv_route_table_az2.id
}



#################################################
################# EIP CREATION ##################
#################################################

# Create EIP for AZ1
resource "aws_eip" "eip_az1" {
  tags = {
    Name = "my_eip_az1"
  }
}

# Create EIP for AZ2
resource "aws_eip" "eip_az2" {
  tags = {
    Name = "my_eip_az2"
  }
}



#################################################
############# NAT GATEWAY CREATION ##############
#################################################

# Create NAT Gateway for AZ1
resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.eip_az1.id
  subnet_id     = aws_subnet.pub_subnet_az1.id

  tags = {
    Name = "nat_gw_az1"
  }
}

# Create NAT Gateway for AZ2
resource "aws_nat_gateway" "nat_az2" {
  allocation_id = aws_eip.eip_az2.id
  subnet_id     = aws_subnet.pub_subnet_az2.id

  tags = {
    Name = "nat_gw_az2"
  }
}
