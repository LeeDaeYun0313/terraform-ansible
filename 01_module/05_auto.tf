
resource "aws_ami_from_instance" "ldy_ami" {

  name               = "${var.name}-ami"
  source_instance_id = aws_instance.ldy_web.id
  depends_on = [
    aws_instance.ldy_web
  ]
}

resource "aws_launch_configuration" "ldy_lacf" {

  name                 = "${var.name}-web"
  image_id             = aws_ami_from_instance.ldy_ami.id
  instance_type        = var.instance_t2
  iam_instance_profile = var.lacf_iam
  security_groups      = [aws_security_group.ldy_websg.id]
  key_name             = var.key
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_placement_group" "ldy_pg" {
  name     = "${var.name}-pg"
  strategy = var.pg_strategy

}

resource "aws_autoscaling_group" "ldy_autogroup" {
 # count          = "${length(var.public_s)}"
  name                      = "${var.name}-autogroup"
  min_size                  = var.auto_min
  max_size                  = var.auto_max
  health_check_grace_period = var.auto_healthcheck_grace_period
  //health_check_type         = var.auto_healthcheck_type
  desired_capacity          = var.auto_desired_capacity
  force_delete              = var.auto_force_delete
  launch_configuration      = aws_launch_configuration.ldy_lacf.name
  vpc_zone_identifier       = [aws_subnet.ldy_pri[0].id,aws_subnet.ldy_pri[1].id]

}

resource "aws_autoscaling_attachment" "ldy_autoattach" {

  autoscaling_group_name = aws_autoscaling_group.ldy_autogroup.id
  alb_target_group_arn   = aws_lb_target_group.ldy_lbtg.arn

}



##was##############################################################

resource "aws_ami_from_instance" "ldy_was_ami" {

  name               = "${var.name}-was-ami"
  source_instance_id = aws_instance.ldy_wasa.id
  depends_on = [
    aws_instance.ldy_wasa
  ]
}


resource "aws_launch_configuration" "ldy_was_lacf" {

  name                 = "${var.name}-was"
  image_id             = aws_ami_from_instance.ldy_was_ami.id
  instance_type        = var.instance
  iam_instance_profile = var.lacf_iam
  security_groups      = [aws_security_group.ldy_wassg.id]
  key_name             = var.key
  
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_placement_group" "ldy_was_pg" {
  name     = "${var.name}-was-pg"
  strategy = var.pg_strategy

}


resource "aws_autoscaling_group" "ldy_was_autogroup" {

  name                      = "${var.name}-was-autogroup"
  min_size                  = var.auto_min
  max_size                  = var.auto_max
  health_check_grace_period = var.auto_healthcheck_grace_period
  //health_check_type         = var.auto_healthcheck_type
  desired_capacity          = var.auto_desired_capacity
  force_delete              = var.auto_force_delete
  launch_configuration      = aws_launch_configuration.ldy_was_lacf.name
  vpc_zone_identifier       = [aws_subnet.ldy_pri[0].id,aws_subnet.ldy_pri[1].id]

 
}

#auto스케일링과 lb 붙이기

#확인해보면 lb 대상그룹에 인스턴스 3개가 붙어 있어야 한다.

resource "aws_autoscaling_attachment" "ldy_was_autoattach" {

  autoscaling_group_name = aws_autoscaling_group.ldy_was_autogroup.id
  alb_target_group_arn   = aws_lb_target_group.ldy_nlbtg.arn

}
