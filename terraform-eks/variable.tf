variable "eks_cluster_name" {
    description = "EKS cluster name"
    type        = string
    default   = "eks-cluster"
}
variable "eks_cluster_version" {
    description = "EKS cluster version"
    type        = number
    default     = 1.30
}
variable "eks_cluster_instance_name" {
    description = "EKS cluster instance name"
    type        = string
    default     = "worker-nodes"
}
variable "eks_cluster_instance_type" {
    description = "EKS cluster instance type"
    type        = string
    default     = "t3.midium"
}
variable "region" {
    description = "AWS region"
    type        = string
    default     = "ap-southeast-1"
}

variable "availability_zones" {
    description = "AWS availability zones"
    type        = list(string)
    default     = ["ap-southeast-1a", "ap-southeast-1b",]
}

variable "addons" {
    description = "EKS cluster addons"
    type        = list(object({
        name = string
        version = string
    }))
    default = [
        {
            name    = "vpc-cni"
            version = "v1.12.2-eksbuild.1"
        },
        {
            name    = "kube-proxy"
            version = "v1.25.6-eksbuild.1"
        },
        {
            name    = "coredns"
            version = "v1.9.3-eksbuild.1"
        },
        {
            name = "aws-ebs-csi-driver"
            version = "v1.23.0-eksbuild.1"
        }

    ]
 }


## VPC variables
 variable "vpc_name" {
    description = "VPC name"
    type        = string
    default     = "eks-vpc"
 }

variable "vpc_cidr" {
     description = "VPC CIDR"
     type        = string
     default     = "10.0.0.3/16"
}
variable "public_subnet_name" {
    description = "public subnet name"
    type        = list(string)
    default     = ["public_subnet_1", "public_subnet_2", "public_subnet_3"]
}
variable "public_subnet_cidr" {
    description = "Public subnet CIDR"
    type        = list(string)
    default     = ["10.0.0.4/24", "10.0.0.5/24", "10.0.0.6/24"]
}

variable "environment" {
    description = "AWS environment"
    type        = string
    default     = "dev"
}
