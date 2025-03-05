# Deploy the AWS Load Balancer Controller to help in creating ingress to access the Web and API


resource "kubernetes_service_account" "aws_load_balancer_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_load_balancer_controller_role.arn
    }
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_iam_role.aws_load_balancer_controller_role,
    kubernetes_config_map.aws_auth,
  ]
}

# Deploy the AWS Load Balancer Controller using Helm
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.11.0" # Specify the version you want to install
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks_cluster.name
  }

  set {
    name  = "serviceAccount.create"
    value = "false" # Disable service account creation
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller" # Use the existing service account
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_load_balancer_controller_role.arn
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.custom_node_group,
    aws_iam_role.aws_load_balancer_controller_role,
    kubernetes_config_map.aws_auth, # Ensure the aws-auth ConfigMap is created
  ]
}

# IAM Role for AWS Load Balancer Controller
resource "aws_iam_role" "aws_load_balancer_controller_role" {
  name = "aws-load-balancer-controller-role"

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
            "${aws_iam_openid_connect_provider.eks_oidc_provider.url}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

# Create the IAM policy for the AWS Load Balancer Controller
resource "aws_iam_policy" "aws_load_balancer_controller_policy" {
  name        = "AWSALBControllerPolicy"
  description = "Policy for the AWS Load Balancer Controller"
  policy      = file("${path.module}/aws-load-balancer-controller-policy.json") # Path to the JSON file
}

# Attach the IAM policy to the IAM role
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller_policy_attachment" {
  role       = aws_iam_role.aws_load_balancer_controller_role.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller_policy.arn
}