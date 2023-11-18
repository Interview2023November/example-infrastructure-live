output "bastion_public_ip" {
  value       = module.bastion.public_ip
  description = "The public IP of the bastion."
}

output "bastion_security_group_id" {
  value       = aws_security_group.bastion.id
  description = "The ID of the bastion security group."
}

output "nat_gateway_id" {
  value       = module.nat_gateway.id
  description = "The ID of the NAT gateway."
}

output "lb_security_group_id" {
  value       = aws_security_group.lb.id
  description = "The ID of the load balancer security group."
}

output "lb_arn" {
  value       = module.load_balancer.arn
  description = "The ARN of the load balancer."
}

output "target_group_arn" {
  value       = module.load_balancer.target_group_arn
  description = "The ARN of the load balancer target group."
}

output "url" {
  value       = module.load_balancer.url
  description = "The URL where the app may be reached."
}
