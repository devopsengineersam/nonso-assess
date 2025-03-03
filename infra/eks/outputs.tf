# Output the EKS cluster name
output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
  description = "The name of the EKS Cluster"
}

output "eks_node_security_group_id" {
  description = "Security group ID of the EKS nodes"
  value       = aws_security_group.eks_node_sg.id
}