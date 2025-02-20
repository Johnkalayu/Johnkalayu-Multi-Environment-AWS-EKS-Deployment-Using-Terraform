resource "aws_eks_cluster" "cluster" {
    name    = var.eks_cluster_name
    version = var.eks_cluster_version
    role_arn = aws_iam_role.eks-cluster-role.arn

    vpc_config {
        vpc_id = var.vpc_name
        subnet_ids = var.public_subnet_ids
        endpoint_public_access = true
        endpoint_private_access = true
    }    
    access_config {
        authentication_mode = ["API_AND_CONFIG_MAP"]
    }
    addons = var.addons

    depends_on = [ 
        aws_iam_role_policy_attachment.eks-cluster-policy,
        aws_iam_role_policy_attachment.eks_compute_policy,
        aws_iam_role_policy_attachment.eks_lodbalancer_policy,
        aws_iam_role_policy_attachment.eks_blockstorage_policy,
        aws_iam_role_policy_attachment.eks-networking-policy
    ]

    tags = {
        Name = var.environment
    }    

}

resource "aws_eks_node_group" "node-group" {
    cluster_name = var.eks_cluster_name
    node_group_name = "worker_nodes"
    node_role_arn = aws_iam_role.eks-node-role.arn
    subnet_ids = var.aws_public_subnet_ids

    scaling_config {
        desired_size = 2
        max_size = 4
        min_size = 1
    }

    update_config {
        max_unavailable = 1
    }
      

    depends_on = [ 
        aws_iam_role_policy_attachment.eks-eks_node_cni_policy,
        aws_iam_role_policy_attachment.eks_node_ec2_policy,
        aws_iam_role_policy_attachment.eks_node_worker_policy
    ]  
    
 
    tags = {
        Name = var.environment
    }
  
}
