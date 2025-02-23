## creating IAM OIDC provider

data "aws_eks_cluster" "eks-cluster" {
    name = var.eks_cluster_name
}
data "aws_eks_cluster_auth" "eks-cluster" {
    name = var.eks_cluster_name
}

output "oicd_issuer_url" {
    value = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

## fetch thumabpring using openssl

resource "null_resource" "thumbprint" {
    provisioner "local-exec" {
        command = <<EOT
        issuer_url=$(aws eks describe-cluster --name ${data.aws_eks_cluster.eks-cluster.name} --query "cluster.identity.oidc.issuer" --output text)
        domain=$(echo $issuer_url | sed -E 's#https://##')
        openssl s_client -servername $domain -showcerts -connect $domain:443 </dev/null 2>/dev/null |
        openssl x509 -fingerprint -noout -sha1 |
        sed 's/://g' | awk -F'=' '{print $2}' > thumbprint.txt
        EOT  
    }

}

data "local_file" "thumbprint" {
    filename = "thumbprint.txt"
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [data.local_file.thumbprint.content]
    url  = data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}


## creating iam police 



resource "aws_iam_policy" "aws_lb_policy" {
    name = "aws_lb_policy"
    policy = file("aws-lb-policy.json")
}

resource "aws_iam_role" "aws_lb_role" {
    name = "aws-eks-cluster-lb-role"

    assume_role_policy = jsonencode({
     Version = "2012-10-17"
     Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Federated = "arn:aws:iam::${data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer}:audiences/eks.amazonaws.com"
        }
        Effect    = "Allow"
        Condition = {
          StringEquals = {
            "${data.aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws-lb-policy-attachment" {
    role = aws_iam_role.aws_lb_role.name
    policy_arn = aws_iam_policy.aws_lb_policy.arn
}
  
## creating aws eks service account names 
resource "kubernetes_service_account" "aws_lb_name" {
    metadata {
        name = "aws-load-balancer-controller-name"
        namespace = "kube-system"

    }
  
}

resource "kubernetes_role_binding" "aws-lb-binding" {
    metadata {
        name = "aws-load-balancer-controller-binding"
        namespace = "kube-system"
    }
    role_ref {
        api_group = "rbac.authorization.k8s.io"
        kind = "Role"
        name = "aws-load-balancer-controller-name"
    }
    subject {
        kind = "service_account"
        name = kubernetes_service_account.aws-lb-name.metadata[0].name
        namespace = "kube-system"
    }

}

## creating helm releas 

resource "helm_release" "aws_lb_controller" {
    name = "aws_lb_controller"
    namespace = "kube-system"
    repository = "https://aws.github.io/eks-charts"
    chart = "aws-load-balancer-controller"
    version = "v2.4.1"


    set {
        name = "clustername"
        value = var.eks_cluster_name
    }
    set {
        name = "serviceAccount.create"
        value = false
    }
    set {
        name = "serviceAccount.name"
        value = kubernetes_service_account.aws-lb-name.metadata[0].name
    }
    set {
        name = "region"
        value = var.region
    }
    set {
        name = "vpcId"
        value = var.vpc_id
    }
    set {
        name  = "replicaCount"
        value = 1
    }
    set {
        name  = "image.repository"
        value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
   }

    depends_on = [ 
        aws_iam_role.aws-lb-role,
        kubernetes_service_account.aws_lb_name
    ]
  
}
