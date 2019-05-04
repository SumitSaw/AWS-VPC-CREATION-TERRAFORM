resource "aws_vpc" "main-vpc" {
  cidr_block = "${var.cidr}"
  
  tags = {
    Name = "VPC-TF"
  }
}
resource "aws_subnet" "subnet-public" {
  vpc_id = "${aws_vpc.main-vpc.id}"
  cidr_block = "${var.cidr-subnet-public}"
  map_public_ip_on_launch = true
  tags = {
     Name = "subnet-public-TF"
     }

}
resource "aws_subnet" "subnet-private" {
  vpc_id = "${aws_vpc.main-vpc.id}"
  cidr_block = "${var.cidr-subnet-private}"
  map_public_ip_on_launch = false
  tags = {
     Name = "subnet-private-TF"
     }

}
resource "aws_internet_gateway" "IGW"{
  vpc_id ="${aws_vpc.main-vpc.id}"
  tags = {
    Name = "IGW-TF"
    }
}

resource "aws_route_table" "route-table-private" {
  vpc_id = "${aws_vpc.main-vpc.id}"
  tags = {
    Name = "route-pvt-TF"
    }

  route {
    cidr_block = "${var.cidr-destination}"
    gateway_id = "${aws_nat_gateway.NAT-GW.id}" #issue
  }

}
resource "aws_route_table" "route-table-public"
{
  vpc_id = "${aws_vpc.main-vpc.id}"
  
  tags = {
    Name = "route-pub-TF"
    }

  route {
      cidr_block = "${var.cidr-destination}"
      gateway_id = "${aws_internet_gateway.IGW.id}"
  }
}


resource "aws_route_table_association" "route-association-public"{
    subnet_id = "${aws_subnet.subnet-public.id}"
    route_table_id = "${aws_route_table.route-table-public.id}"
  } 
resource "aws_route_table_association" "route-association-private"{
  route_table_id = "${aws_route_table.route-table-private.id}"
  subnet_id = "${aws_subnet.subnet-private.id}"
  
}

resource "aws_eip" "eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.IGW"]
}

resource "aws_nat_gateway" "NAT-GW"
{
  subnet_id ="${aws_subnet.subnet-public.id}"
  allocation_id = "${aws_eip.eip.id}"
  depends_on = ["aws_internet_gateway.IGW"]
  
}
  


