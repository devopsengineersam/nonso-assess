# IAM Role for EBS CSI Driver addon
resource "aws_iam_role" "ebs_csi_driver_role" {
  name = "eks-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc_provider.arn
        }
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.eks_oidc_provider.url}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

# Attach the AWS EBS CSI Driver policy to the IAM role
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ebs_csi_driver_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# EBS CSI Driver Add-On
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name      = aws_eks_cluster.eks_cluster.name
  addon_name        = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver_role.arn

  depends_on = [
    aws_eks_node_group.custom_node_group,
    aws_iam_role.ebs_csi_driver_role,
    aws_iam_role_policy_attachment.ebs_csi_driver_policy,
  ]
}