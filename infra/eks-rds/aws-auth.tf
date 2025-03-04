# Create the aws-auth ConfigMap
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<YAML
    - rolearn: ${aws_iam_role.eks_node_group_role.arn}
    username: system:node:{{EC2PrivateDNSName}}
    groups:
        - system:bootstrappers
        - system:nodes
    - rolearn: arn:aws:iam::533267037417:role/Admin
    username: admin-user
    groups:
        - system:masters
    YAML

        mapUsers = <<YAML
    - userarn: arn:aws:iam::533267037417:user/devopsam
    username: devopsam
    groups:
        - system:masters
    YAML
    }

  depends_on = [aws_eks_cluster.eks_cluster]
}