resource "aws_lb" "ldy_lb" {
  name               = "${var.name}-alb"
  internal           = var.load_internal
  load_balancer_type = var.load_type
  security_groups    = [aws_security_group.ldy_albsg.id]
  subnets            = [aws_subnet.ldy_pub[0].id,aws_subnet.ldy_pub[1].id]
  

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_lb_target_group" "ldy_lbtg" {
  name     = "${var.name}-lbtg"
  port     = var.http_port
  protocol = var.prot_HTTP
  vpc_id   = aws_vpc.ldy_vpc.id
  health_check {
    enabled             = var.health_enabled
    healthy_threshold   = var.health_threshold
    interval            = var.health_interval
    matcher             = var.health_matcher
    path                = var.health_path
    port                = var.health_prot
    protocol            = var.prot_HTTP
    timeout             = var.health_timeout
    unhealthy_threshold = var.health_unhealthy_threshold

  }
}

resource "aws_lb_listener" "ldy_lblist" {
  load_balancer_arn = aws_lb.ldy_lb.arn
  port              = var.http_port
  protocol          = var.prot_HTTP

  default_action {
    type             = var.lb_listner_action_type
    target_group_arn = aws_lb_target_group.ldy_lbtg.arn

  }
}

###was

resource "aws_lb" "ldy_nlb" {
    name                = "ldy-nlb"
    internal            = true
    load_balancer_type  = "network"
    subnets             = [aws_subnet.ldy_pri[0].id,aws_subnet.ldy_pri[1].id]
    
    tags = {
        Name = "ldy-nlb"
    }


}

resource "aws_lb_target_group" "ldy_nlbtg" {
    name            = "ldy-nlbtg"
    port            = 8080
    protocol        = "TCP"
    vpc_id          = aws_vpc.ldy_vpc.id 
    health_check {
      enabled               = true
      healthy_threshold     = 2
      interval              = 10
      port                  = "traffic-port"
      protocol              = "TCP"
      unhealthy_threshold   = 2
      
    }   
}

resource "aws_lb_listener" "ldy_nlblist" {
    load_balancer_arn       = aws_lb.ldy_nlb.arn
    port                    = 80
    protocol                = "TCP"

    default_action{
        type                     = "forward"
        target_group_arn    = aws_lb_target_group.ldy_nlbtg.arn  
        
    } 
}

