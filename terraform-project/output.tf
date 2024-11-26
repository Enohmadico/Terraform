output "instance_ips" { value = aws_autoscaling_group.asg.instance_ips }

output "vpc_id" { value = aws_vpc.main.id }