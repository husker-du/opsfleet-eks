output "vpc_id" {
  description = "The id of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "intra_subnet_ids" {
  description = "Intra subnet CIDR blocks"
  value       = aws_subnet.intra[*].id
}

output "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  value       = aws_subnet.private[*].cidr_block
}

output "intra_subnet_cidrs" {
  description = "Intra subnet CIDR blocks"
  value       = aws_subnet.intra[*].cidr_block
}
