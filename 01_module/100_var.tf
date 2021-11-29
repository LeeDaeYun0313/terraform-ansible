variable "name" {
  type = string
  # default = "ldy"
}

variable "avazone" {
  type = list(any)
  # default = ["a","c"]
}

variable "region" {
  type = string
  # default = "ap-northeast-2"
}

variable "key" {
  type = string
  # default = "tf-key1"
}

variable "cidr" {
  type = string
  # default = "0.0.0.0/16"
}

variable "cidr_v6" {
  type    = string
 # default = "::/0"
}

variable "cidr_main" {
  type = string
  # default = "10.0.0.0/16"
}

variable "public_s" {
  type = list(any)
  # default = ["10.0.0.0/24","10.0.2.0/24"]
}

variable "private_s" {
  type = list(any)
  # default = ["10.0.1.0/24","10.0.3.0/24"]
}

variable "private_dbs" {
  type = list(any)
  # default = ["10.0.4.0/24","10.0.5.0/24"]
}

variable "private_ip" {
  type = string
  # default   = "10.0.0.11"
}

variable "private_bastionip" {
  type = string
  # default   = "10.0.0.10"
}

variable "rds_mysql_port" {
  type = string
  # default   = "63306"
}

variable "ssh_port" {
  type    = number
  # default = 22
}

variable "tomcat_port" {
  type    = number
  # default = 22
}

variable "http_port" {
  type    = number
 # default = 80
}

variable "mysql_port" {
  type    = number
  #default = 3306
}

variable "zero_port" {
  type    = number
  #default = 0
}

variable "under_port" {
  type    = number
  #default = -1
}

variable "prot_tcp" {
  type    = string
  #default = "tcp"
}

variable "prot_http" {
  type    = string
 # default = "http"
}

variable "prot_icmp" {
  type    = string
 # default = "icmp"
}

variable "prot_ssh" {
  type    = string
 # default = "ssh"
}

variable "prot_sql" {
  type    = string
  #default = "sql"
}

variable "instance" {
  type    = string
 # default = "t2.micro"
}

variable "instance_t2" {
  type    = string
 # default = "t2.micro"
}
variable "load_type" {
  type    = string
 # default = "application"
}

variable "load_internal" {
  type    = bool
# default = false
}

variable "health_enabled" {
  type = bool
 # default = true
}

variable "health_threshold" {
  type    = number
 # default = 3
}

variable "health_interval" {
  type    = number
 # default = 5
}

variable "health_matcher" {
  type    = string
 # default = "200"
}

variable "health_path" {
  type    = string
 # default = "/health.html"
}

variable "health_prot" {
  type    = string
 # default = "traffic-port"
}

variable "health_timeout" {
  type    = number
 # default = 2
}

variable "health_unhealthy_threshold" {
  type    = number
 # default = 2
}

variable "lb_listner_action_type" {
  type = string
# default = "forward"
}

variable "lacf_iam" {
  type = string
 # default = "admin_role"
}

variable "pg_strategy" {
  type = string
 # default = "cluster"
}

variable "auto_min" {
  type = number
 # default = 2
}

variable "auto_max" {
  type = number
  #default = 8
}

variable "auto_healthcheck_grace_period" {
  type = number
 # default = 300
}

variable "auto_healthcheck_type" {
  type = string
 # default = "ELB"
}

variable "auto_desired_capacity" {
  type = number
 # default = 2
}

variable "auto_force_delete" {
  type = bool
 # default = true
}

variable "db_storage" {
  type = number
 # default = 20
}

variable "db_storage_type" {
  type = string
 # default = "gp2"
}

variable "db_engine" {
  type = string
 # default = "mysql"
}
variable "db_engine_version" {
  type = string
 # default = "8.0"
}

variable "db_instacnce_class" {
  type = string
 # default = "db.t2.micro"
}

variable "db_name" {
  type = string
 # default = "mydb"
}

variable "db_identifier" {
  type = string
 # default = "mydb"
}

variable "db_username" {
  type = string
 # default = "root"
}

variable "db_password" {
  type = string
 # default = "It12345!"
}

variable "db_parameter_group_name" {
  type = string
 # default = "default.mysql8.0"
}

variable "db_avazone" {
  type = string
  #default = "ap-northeast-2a"
}

variable "db_snapshot" {
  type = bool
 # default = true
}

variable "prot_HTTP" {
  type = string
 # default = "HTTP" 
}

variable "ami" {
  type = string
# default = "ami-0e4a9ad2eb120e054"
}