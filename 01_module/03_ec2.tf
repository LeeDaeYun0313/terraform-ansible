
resource "aws_security_group" "ldy_bastionsg"{
  name        = "Allow-bastion"
  description = "ssh"
  vpc_id      = aws_vpc.ldy_vpc.id
 
  ingress = [
    {
      description      = "ch-ssh"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      protocol         = var.prot_tcp
      cidr_blocks      = ["39.113.225.124/32"]  #my ip 넣으면 됩니다!
     # cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]
  egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 tags = {
    Name = "${var.name}-bastion-sg"
  }
 }

resource "aws_security_group" "ldy_websg"{
  name        = "Allow-WEB"
  description = "http-ssh"
  vpc_id      = aws_vpc.ldy_vpc.id

 ingress = [
    {
      description      = "ch-ssh"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      protocol         = var.prot_tcp
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      security_groups  = [aws_security_group.ldy_bastionsg.id]
      prefix_list_ids  = null
      self             = null
    },
    {
      description      = var.prot_http
      from_port        = var.http_port
      to_port          = var.http_port
      protocol         = var.prot_tcp
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 tags = {
    Name = "${var.name}-web-sg"
  }
}

resource "aws_security_group" "ldy_wassg"{
  name        = "Allow-WAS"
  description = "tomcat-bastionsg"
  vpc_id      = aws_vpc.ldy_vpc.id
 
ingress = [
    {
      description      = "ch-ssh"
      from_port        = var.ssh_port
      to_port          = var.ssh_port
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      protocol         = var.prot_tcp
      security_groups  = [aws_security_group.ldy_bastionsg.id]
      prefix_list_ids  = null
      self             = null
    },
    {
      description     = "tomcat"
      from_port       = var.tomcat_port
      to_port         = var.tomcat_port
      cidr_blocks     = null
      ipv6_cidr_blocks= null
      protocol        = "tcp"
      security_groups = [aws_security_group.ldy_websg.id]
      prefix_list_ids = null
      self            = null
    }
  ]

 egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]
 tags = {
    Name = "${var.name}-was-sg"
  }
 }

resource "aws_security_group" "ldy_dbsg"{
  name        = "Allow-db"
  description = "mysql-port"
  vpc_id      = aws_vpc.ldy_vpc.id
 ingress = [
 {
      description      = var.prot_sql
      from_port        = var.mysql_port
      to_port          = var.mysql_port
      cidr_blocks      = null
      ipv6_cidr_blocks = null      
      protocol         = var.prot_tcp
      security_groups  = [aws_security_group.ldy_wassg.id]
      prefix_list_ids  = null
      self             = null
    }
 ]
egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]

 tags = {
    Name = "${var.name}-db-sg"
  }
 }

resource "aws_security_group" "ldy_albsg"{
  name        = "Allow-alb"
  description = "http"
  vpc_id      = aws_vpc.ldy_vpc.id
  ingress = [
 {
      description      = var.prot_http
      from_port        = var.http_port
      to_port          = var.http_port
      protocol         = var.prot_tcp
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
]
egress = [
    {
      description      = "ALL"
      from_port        = var.zero_port
      to_port          = var.zero_port
      protocol         = "-1"
      cidr_blocks      = [var.cidr]
      ipv6_cidr_blocks = [var.cidr_v6]
      security_groups  = null
      prefix_list_ids  = null
      self             = null
    }
  ]
 tags = {
    Name = "${var.name}-alb-sg"
  }
 }
 
##여기까지 보안그룹 설정##

##########################

##bastion ##
resource "aws_instance" "Explorer_bastion" {

  ami                    = var.ami
  instance_type          = var.instance
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.ldy_bastionsg.id]
  availability_zone      = "${var.region}${var.avazone[0]}"
  private_ip             = var.private_bastionip
  subnet_id              = aws_subnet.ldy_pub[0].id
  user_data              = file("./../01_module/control.sh")
  tags = {
    Name = "${var.name}-bastion"
  }
}

resource "aws_eip" "Explorer_bastion_eip" {
 
  vpc                       = true
  instance                  = aws_instance.Explorer_bastion.id
  associate_with_private_ip = var.private_bastionip
  depends_on                = [aws_internet_gateway.ldy_igw]

}
##bastion ##



##web ##
resource "aws_instance" "ldy_web" {

  ami                    = var.ami
  instance_type          = var.instance_t2
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.ldy_websg.id]
  availability_zone      = "${var.region}${var.avazone[1]}"
  private_ip             = var.private_ip
  subnet_id              = aws_subnet.ldy_pub[1].id
  user_data              = file("./../01_module/install_seoul.sh")

  tags = {
    Name = "${var.name}-web"
  }
}

resource "aws_eip" "ldy_web_eip" {
 
  vpc                       = true
  instance                  = aws_instance.ldy_web.id
  associate_with_private_ip = var.private_ip
  depends_on                = [aws_internet_gateway.ldy_igw]

}


####was


resource "aws_instance" "ldy_wasa" {
    ami                         = var.ami
    instance_type               = var.instance
    key_name                    = var.key
    vpc_security_group_ids      = [aws_security_group.ldy_wassg.id]
    availability_zone           = "ap-northeast-2c"
    private_ip                  = "10.0.2.12"
    subnet_id                   = aws_subnet.ldy_pub[1].id
    user_data                   = file("./../01_module/install_was.sh")

    tags = {
      Name = "${var.name}-was"
    }
}

resource "aws_eip" "ldy_was_eip" {
  vpc = true
  instance = aws_instance.ldy_wasa.id
  associate_with_private_ip = "10.0.2.12"
  depends_on = [aws_internet_gateway.ldy_igw]
  
}

