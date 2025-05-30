{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "arn:aws:s3:::sockshop-mysql-backups-bucket"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
      "Resource": "arn:aws:s3:::sockshop-mysql-backups-bucket/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:CreateSecurityGroup",
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:RevokeSecurityGroupIngress",
        "ec2:DeleteSecurityGroup",
        "ec2:DescribeRouteTables",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:DescribeNetworkInterfaces",
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:AttachNetworkInterface",
        "ec2:DetachNetworkInterface"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:DescribeLoadBalancers",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:ConfigureHealthCheck",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:CreateLoadBalancerListeners",
        "elasticloadbalancing:DescribeLoadBalancerListeners",
        "elasticloadbalancing:AddListenerCertificates",
        "elasticloadbalancing:DeleteLoadBalancerListeners",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyLoadBalancerListener",
        "elasticloadbalancingv2:DescribeLoadBalancers",
        "elasticloadbalancingv2:CreateLoadBalancer",
        "elasticloadbalancingv2:CreateTargetGroup",
        "elasticloadbalancingv2:DescribeTargetGroups",
        "elasticloadbalancingv2:RegisterTargets",
        "elasticloadbalancingv2:DeregisterTargets",
        "elasticloadbalancingv2:ModifyTargetGroupAttributes",
        "elasticloadbalancingv2:ModifyTargetGroup",
        "elasticloadbalancingv2:DeleteTargetGroup",
        "elasticloadbalancingv2:CreateListener",
        "elasticloadbalancingv2:DescribeListeners",
        "elasticloadbalancingv2:ModifyListener",
        "elasticloadbalancingv2:AddListenerCertificates",
        "elasticloadbalancingv2:DeleteListener",
        "elasticloadbalancingv2:DeleteLoadBalancer",
        "elasticloadbalancingv2:ModifyLoadBalancerAttributes"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "rds:DescribeDBInstances",
        "rds:CreateDBInstance",
        "rds:DeleteDBInstance",
        "rds:ModifyDBInstance",
        "rds:RebootDBInstance",
        "rds:RestoreDBInstanceFromSnapshot",
        "rds:CreateDBSnapshot",
        "rds:DeleteDBSnapshot",
        "rds:DescribeDBSnapshots",
        "rds:DescribeDBClusters",
        "rds:CreateDBCluster",
        "rds:DeleteDBCluster",
        "rds:ModifyDBCluster",
        "rds:RebootDBCluster",
        "rds:RestoreDBClusterFromSnapshot",
        "rds:CreateDBClusterSnapshot",
        "rds:DeleteDBClusterSnapshot",
        "rds:DescribeDBClusterSnapshots",
        "rds:AddTagsToResource",
        "rds:RemoveTagsFromResource"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecrets"
      ],
      "Resource": [
        "arn:aws:secretsmanager:us-east-1:${account_id}:secret:mysql-*"
      ]
    }
  ]
}
