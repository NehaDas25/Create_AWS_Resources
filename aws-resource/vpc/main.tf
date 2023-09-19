###########################################################
                     VPC - CIDR Block
###########################################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.basename}-VPC"
  }
}

###########################################################
                 VPC - Internet Gateway
###########################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.basename}-IG"
  }
}

###########################################################
                    Public Subnets CIDRs
###########################################################
resource "aws_subnet" "public_subnets" {
  count             = length(locals.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(locals.azs, count.index)
  cidr_block        = element(var.public_subnet_cidrs, count.index)

  tags = {
    Name = "${var.basename}-Public-Subnet-${count.index + 1}"
  }
}

###########################################################
                    Private Subnets CIDRs
###########################################################
resource "aws_subnet" "private_subnets" {
  count             = length(locals.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(locals.azs, count.index)
  cidr_block        = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name = "${var.basename}-Private-Subnet-${count.index + 1}"
  }
}

###########################################################
               Elastic IP for NAT GW
###########################################################
resource "aws_eip" "EIP_Nat_GW" {
  count = length(aws_subnet.private_subnets)
  vpc   = true
  tags = {
    Name = "${var.basename}-EIP-${count.index + 1}"
  }
}

###########################################################
                         Nat Gateway
###########################################################
resource "aws_nat_gateway" "Nat_Gateways" {
  count         = length(aws_subnet.private_subnets)
  allocation_id = element(aws_eip.EIP_Nat_GW, count.index).id
  subnet_id     = element(aws_subnet.private_subnets, count.index).id
  tags = {
    Name = "${var.basename}-NAT-${count.index + 1}"
  }
}

###########################################################
                    Public Subnet Route Table
###########################################################
resource "aws_route_table" "public_subnets_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "${var.basename}-Public-Subnet-RT"
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets_rt.id
}

###########################################################
                    Private Subnet Route Table
###########################################################
resource "aws_route_table" "private_subnets" {
  count  = length(aws_nat_gateway.Nat_Gateways)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = element(aws_nat_gateway.Nat_Gateways, count.index).id
  }

  tags = {
    Name = "{var.basename}-Private-Subnet-RT"
  }
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
  route_table_id = element(aws_route_table.private_subnets[*].id, count.index)
}