resource "aws_opensearch_domain" "OpenSearch-VectorStore" {
  domain_name = var.OpenSearchVectorStore
  engine_version = var.OpenSearchEngineVersion

  cluster_config {
    instance_type = var.OpenSearchInstanceType
    instance_count = var.NumberOfInstance
    # zone_awareness_config {
    #   availability_zone_count = 3
    # }
    # zone_awareness_enabled = true
  }

  advanced_security_options {
    enabled = true
    anonymous_auth_enabled = false
    internal_user_database_enabled = true
    master_user_options {
      master_user_name = var.OpenSearchMasterUserName
      master_user_password = var.OpenSearchMasterUserPassword
    }
  } 

  encrypt_at_rest {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  node_to_node_encryption {
    enabled = true
  }

  ebs_options {
    ebs_enabled = true
    volume_size = var.EBSVolumeSize
    volume_type = "gp3"
  }

  access_policies = <<CONFIG
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Action": "es:*",
              "Principal": "*",
              "Effect": "Allow",
              "Resource": "arn:aws:es:${var.aws_region}:${var.AccountNumber}:domain/${var.OpenSearchVectorStore}/*"
          }
      ]
  }
  CONFIG
}