resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = {
    Name = var.Name
  }
}

#creating different subnets
resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_sub1_cidr
  availability_zone       = var.aws_availability_zone3
  map_public_ip_on_launch = true
}


resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_sub2_cidr
  availability_zone = var.aws_availability_zone1
}

resource "aws_subnet" "privat1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_sub1_cidr
  availability_zone       = var.aws_availability_zone2
  map_public_ip_on_launch = false
}


resource "aws_subnet" "privat2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_sub2_cidr
  availability_zone       = var.aws_availability_zone2
  map_public_ip_on_launch = false
}


# Create an internet gateway and associate it with the VPC
resource "aws_internet_gateway" "Igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.aws_internet_gateway_tag
  }
}

#Create an Elastic IP address
resource "aws_eip" "ngw-eip" {
  domain = "vpc"
}


# Creating a Nat gateway for public subnet2
resource "aws_nat_gateway" "Natgw2" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.public2.id

  tags = {
    Name = var.aws_nat_gateway_tag2
  }

  depends_on = [aws_internet_gateway.Igw]
}


# Create a public route table with a default route to the internet gateway
resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.main.id

  # # Create a default route for the internet gateway with destination 0.0.0.0/0

  route {
    cidr_block = var.aws_internet_gateway_cirdr_block
    gateway_id = aws_internet_gateway.Igw.id
  }

  tags = {
    Name = var.aws_public_rt_tag
  }
}


# Creates a private route table with a default route to the NAT gateway
resource "aws_route_table" "prt_rt" {
  vpc_id = aws_vpc.main.id

  # Route for internet-bound traffic via the nat Gateway
  route {
    cidr_block     = var.aws_internet_gateway_cirdr_block
    nat_gateway_id = aws_nat_gateway.Natgw2.id
  }

  tags = {
    Name = var.aws_private_rt_tag1
  }
}

# Associates the public route table with the public subnet 1

resource "aws_route_table_association" "pub-sub1-rt-ass" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.pub_rt.id
}

# Associates the public route table with the public subnet 2

resource "aws_route_table_association" "pub-sub2-rt-ass" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.pub_rt.id
}

# Associates the private route table with the private subnet 1
resource "aws_route_table_association" "priv-sub1-rt-ass" {
  subnet_id      = aws_subnet.privat1.id
  route_table_id = aws_route_table.prt_rt.id
}

#Associates the private route table with the private subnet 2
resource "aws_route_table_association" "private-sub2-rt-ass" {
  subnet_id      = aws_subnet.privat2.id
  route_table_id = aws_route_table.prt_rt.id
}

# Create security group for ALB
resource "aws_security_group" "alb-sg" {
  name        = var.alb_sg_name
  description = var.alb_sg_description
  vpc_id      = aws_vpc.main.id

  #inbound rules 
  #http acess from anywhere 
  ingress {
    description = "Allow HTTP Traffic"
    from_port   = var.http_port
    to_port     = var.http_port
    protocol    = "tcp"
    cidr_blocks = var.alb_sg_ingress_cidr_blocks
  }

  # SSH access from anywhere
  ingress {
    description = "Allow SSH Traffic"
    from_port   = var.ssh_port
    to_port     = var.ssh_port
    protocol    = "tcp"
    cidr_blocks = var.alb_sg_ingress_cidr_blocks



  }

  # Inbound Rule
  # Allow all egress traffic
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = var.alb_sg_egress_cidr_blocks
  }

}

# Create a new load balancer
resource "aws_lb" "pub-sub-alb" {
  name            = var.public_subnet_alb_name
  subnets         = [aws_subnet.public1.id, aws_subnet.public2.id]
  security_groups = [aws_security_group.alb-sg.id]
}




##Create a target group for the load balancer
resource "aws_lb_target_group" "alb_tg" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  # Set the health check configuration for the target group
  health_check {
    interval = 60
    path     = "/"
    port     = 80
    timeout  = 45
    protocol = "HTTP"

  }

}

# Create ALB listener
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.pub-sub-alb.id
  port              = "80"
  protocol          = "HTTP"

  # Set the default action for the listener
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.id
  }
}


# Creating Security Group for ASG Launch Template
resource "aws_security_group" "lt-sg" {
  name   = var.lt_sg_group_name
  vpc_id = aws_vpc.main.id

  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port       = var.http_port
    to_port         = var.http_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  # SSH access from anywhere
  ingress {
    from_port       = var.ssh_port
    to_port         = var.ssh_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.alb_sg_egress_cidr_blocks
  }
}

# Create an autoscaling group with the specified configurations
resource "aws_autoscaling_group" "asg" {
  name                = var.asg_name
  min_size            = var.asg_min_size
  max_size            = var.asg_max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = [aws_subnet.privat1.id, aws_subnet.privat2.id]
  launch_template {
    id = aws_launch_template.lt-asg.id
  }
}
# Create a launch template with the specified configurations
resource "aws_launch_template" "lt-asg" {
  name          = var.asg_lt_name
  image_id      = var.lt_asg_ami
  instance_type = var.lt_asg_instance_type
  key_name      = "keypair"
  #key_name               =var.lt_asg_key_name 
  vpc_security_group_ids = [aws_security_group.lt-sg.id]
  user_data              = filebase64("./apach.sh")
}