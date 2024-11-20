variable "cidr_block" {
  description = "aws_cidr"
  default     = "10.0.0.0/16"
}
variable "Name" {
  default = "aws-vpc"
}

#public_subnet1 
variable "public_sub1_cidr" {
  default = "10.0.1.0/24"
}

# #  # public_subet 2    
variable "public_sub2_cidr" {
  default = "10.0.2.0/24"
}

variable "aws_availability_zone1" {
  default = "us-east-1a"
}
variable "aws_availability_zone3" {
  default = "us-east-1c"

}

# # # private_subnet1 cidr 
variable "private_sub1_cidr" {
  default = "10.0.4.0/24"

}
## private subnet2 cidr 
variable "private_sub2_cidr" {
  default = "10.0.5.0/24"
}

variable "aws_availability_zone2" {
  default = "us-east-1b"
}

variable "aws_internet_gateway_tag" {
  default = "my_gateway"
}

variable "aws_nat_gateway_tag1" {
  default = "gw Natgw1"
}


variable "aws_nat_gateway_tag2" {
  default = "gw NAT2"
}

variable "aws_internet_gateway_cirdr_block" {
  default = "0.0.0.0/0"
}

variable "aws_public_rt_tag" {
  default = "pub_rt"
}

variable "aws_private_rt_tag1" {
  default = "prt_rt1"
}

variable "aws_private_rt_tag2" {
  default = "prt_rt2"
}

variable "alb_sg_name" {
  default = "alb-sg"

}

variable "alb_sg_description" {
  default = "security_group for alb"

}

variable "alb_sg_ingress_cidr_blocks" {
  default = ["0.0.0.0/0"]

}

variable "http_port" {
  default = 80
}

variable "ssh_port" {
  default = 22

}

variable "alb_sg_egress_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "public_subnet_alb_name" {
  default = "public-subnet-alb"

}

variable "target_group_name" {
  default = "alb-ts"

}
variable "lt_sg_group_name" {
  default = "lt-sg"

}

variable "asg_min_size" {
  default = "1"

}

variable "asg_name" {
  default = "asg"

}
variable "asg_max_size" {
  default = "3"

}
variable "desired_capacity" {
  default = 2

}
variable "asg_lt_name" {
  default = "asg-lt"
}
variable "lt_asg_ami" {
  default = "ami-063d43db0594b521b"
}
variable "lt_asg_instance_type" {
  default = "t2.micro"

}

#variable "lt_asg_key_name" {
#default ="keypair"
#}

