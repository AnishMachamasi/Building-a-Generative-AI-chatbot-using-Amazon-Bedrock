# resource "aws_sagemaker_endpoint" "EmbeddingEndpoint" {
#   name = var.SagemakerEmbeddingEndpoint
#   endpoint_config_name = aws_sagemaker_endpoint_configuration.ec.name
# }

# resource "aws_sagemaker_endpoint_configuration" "ec" {
#   name = var.SagemakerEmbeddingEndpointConfiguration

#   production_variants {
#     variant_name           = "ALLTraffic"
#     model_name             = aws_sagemaker_model.EmbeddingModel.name
#     initial_instance_count = 1
#     instance_type          = var.SagemakerEmbeddingModelInstance
#     initial_variant_weight = 1
#     # serverless_config {
#     #   max_concurrency = var.MaxConcurrentInvocation
#     #   memory_size_in_mb = var.MemoryForServerlessEndpoint
#     # }
#   }

#   tags = {
#     Name = "foo"
#   }
# }

# resource "aws_sagemaker_model" "EmbeddingModel" {
#   name               = var.SagemakerEmbeddingModel
#   execution_role_arn = aws_iam_role.sagemaker_role.arn

#   primary_container {
#     image = "763104351884.dkr.ecr.${var.aws_region}.amazonaws.com/huggingface-pytorch-inference:1.10.2-transformers4.17.0-gpu-py38-cu113-ubuntu20.04"
#     model_data_url = "s3://jumpstart-cache-prod-${var.aws_region}/huggingface-infer/prepack/v1.0.0/infer-prepack-huggingface-textembedding-all-MiniLM-L6-v2.tar.gz"
#     environment = {
#         "SAGEMAKER_MODEL_SERVER_WORKERS":"1"
#     }
#     mode = "SingleModel"
#   }
# }

# resource "aws_iam_role" "sagemaker_role" {
#   name = var.SagemakerEmbeddingModelRoleName

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "sagemaker.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_policy_attachment" "sagemaker_policy_attachment" {
#   name       = "sagemaker-policy-attachment-anish"
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"  # Attach more policies if needed
#   roles      = [aws_iam_role.sagemaker_role.name]
# }

