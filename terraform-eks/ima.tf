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
    name = "eks-admin-group-policy"
    group = aws_iam_group.eks-admin-group.name
    policy = aws_iam_user_policy.eks-admin-policy.policy
  
}

  

