resource "aws_eip" "lb_ip" {
  # instance = aws_instance.web.id
  vpc = true
}

resource "aws_nat_gateway" "ldy_natgate" {
  allocation_id = aws_eip.lb_ip.id
  subnet_id     = aws_subnet.ldy_pub[0].id
  tags = {
    Name = "${var.name}-natgate-a"
  }
}

resource "aws_route_table" "ldy_natgateroutetable" {
  vpc_id = aws_vpc.ldy_vpc.id
  route {
    cidr_block = var.cidr
    gateway_id = aws_nat_gateway.ldy_natgate.id
  }
  tags = {
    Name = "${var.name}-nga-rta"
  }
}

resource "aws_route_table_association" "ldy_ngartas" {
  count          = "${length(var.private_s)}"
  subnet_id      = aws_subnet.ldy_pri[count.index].id
  route_table_id = aws_route_table.ldy_natgateroutetable.id
}

