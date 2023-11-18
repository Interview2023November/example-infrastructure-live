output "id" {
  value       = module.vpc.id
  description = "The ID of the VPC."
}

output "dmz_public_subnet_ids" {
  value       = module.vpc.dmz_public_subnet_ids
  description = "The IDs of the DMZ public subnets."
}

output "front_end_private_subnet_id" {
  value       = module.vpc.front_end_private_subnet_id
  description = "The ID of the front end private subnet."
}

output "back_end_private_subnet_ids" {
  value       = module.vpc.back_end_private_subnet_ids
  description = "The IDs of the back end subnets."
}

output "dmz_public_route_table_id" {
  value       = module.vpc.dmz_public_route_table_id
  description = "The ID of the DMZ public route table."
}

output "private_route_table_id" {
  value       = module.vpc.private_route_table_id
  description = "The ID of the private route table."
}
