resource "aws_iam_user" "eks-admin" {
    name = "eks-admin"
    path = "/system/"
   
  tags = {
      ENVIRONMENT = "dev"  
      Name = "admin"
    }
}


resource "aws_iam_user_policy" "eks-admin-policy" {
    name = "eks-admin-policy"
    user = aws_iam_user.eks-admin.name
  
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "eks:*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_user" "user1" {
    name = "user1"
    path = "/system/"
   
  tags = {
      ENVIRONMENT = "dev"  
      Name = "user1"
    }
  
}
resource "aws_iam_user_policy" "user1_policy" {
    name = "user1_policy"
    user = aws_iam_user.user1.name
  
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "eks:*",
      "Resource": "*"
    }
  ]
  
}
EOF
}

resource "aws_iam_group" "eks-admin-group" {
    name = "eks-admin-group"
    path = "/system/"
}


resource "aws_iam_group_membership" "eks-admin-group-membership" {
    name = "eks-admin-group-membership"
    group = aws_iam_group.eks-admin-group.name
    users = [
        aws_iam_user.eks-admin.name,
        aws_iam_user.user1.name
    
    ]
}

resource "aws_iam_group_policy" "eks-admin-group-policy" {
  name  = "eks-admin-group-policy"
  group = aws_iam_group.eks-admin-group.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "eks:*",
      "Resource": "*"
    }
  ]
}
EOF
}


## eks cluster iam roles
resource "aws_iam_role" "eks-cluster-role" {
  name = "eks-cluster-example"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role = aws_iam_role.eks-cluster-role.name
}
resource "aws_iam_role_policy_attachment" "eks-networking-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks_compute_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role = aws_iam_role.eks-cluster-role.name
}

resource "aws_iam_role_policy_attachment" "eks_blockstorage_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role = aws_iam_role.eks-cluster-role.name

}

resource "aws_iam_role_policy_attachment" "eks_lodbalancer_policy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancerControllerPolicy"
  role = aws_iam_role.eks-cluster-role.name
  
}

## worker node iam role
resource "aws_iam_role" "node" {
  name = "eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks-node-Worker-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.eks-node-role.name
}
resource "aws_iam_role_policy_attachment" "eks_node-ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEc2containerRegistryReadOnly"
  role = aws_iam_role.eks-node-role.name
}
resource "aws_iam_role_policy_attachment" "eks_node_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role = aws_iam_role.eks-node-role.name
}
