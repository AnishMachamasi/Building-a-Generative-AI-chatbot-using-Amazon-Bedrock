data "archive_file" "lambda_delete_zip" {
  type = "zip"
  source_file = "./LambdaUpdatingMetadatatoOpenSearch/lambda_function.py"
  output_path = "LambdaUpdatingMetadatatoOpenSearch.zip"
}

resource "aws_lambda_function" "sqs_lambda_function_deleting" {
  function_name    = var.lambdaDeleteEmbedding
  role             = aws_iam_role.lambda_delete.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"  # Update with the appropriate runtime
  filename         = data.archive_file.lambda_delete_zip.output_path
  source_code_hash = data.archive_file.lambda_delete_zip.output_base64sha256
  publish = true
  timeout = 900
  memory_size = 3008

  # Attach the Lambda layer to the function
  layers = [aws_lambda_layer_version.layer.arn]
}

resource "aws_iam_role" "lambda_delete" {
  name = var.lambdaDeleteEmbeddingRole

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  #Lambda Basic Execution policy
  inline_policy {
    name = "AWSLambdaBasicExecutionRole"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "logs:CreateLogGroup",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    })
  }
  #Full access to S3
  inline_policy {
    name = "AmazonS3FullAccess"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "s3:*",
              "s3-object-lambda:*"
            ],
            "Resource" : "*"
          }
        ]
      }
    )
  }
  #Full access to Opensearch
  inline_policy {
    name = "AmazonOpenSearchServiceFullAccess"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Action": [
                        "es:*"
                    ],
                    "Resource": "*"
                }
            ]
        }
    )
  }
  #Full access to SQS
  inline_policy {
    name = "AmazonSQSFullAccess"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "sqs:*"
            ],
            "Resource" : "*"
          }
        ]
      }
    )
  }

  #access to the InvokeEndpoint
  inline_policy {
    name = "InvokeEndpoint"
    policy = jsonencode(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "VisualEditor0",
                    "Effect": "Allow",
                    "Action": "sagemaker:InvokeEndpoint",
                    "Resource": "*"
                }
            ]
        }
    )
  }

  #Read Only Access to SSM
  inline_policy {
    name = "AmazonSSMReadOnlyAccess"
    policy = jsonencode(
      {
          "Version": "2012-10-17",
          "Statement": [
              {
                  "Effect": "Allow",
                  "Action": [
                      "ssm:Describe*",
                      "ssm:Get*",
                      "ssm:List*"
                  ],
                  "Resource": "*"
              }
          ]
      }
    )
  }

    #Read Only Access to SSM
  inline_policy {
    name = "BedRockFullAccess"
    policy = jsonencode(
      {
          "Version": "2012-10-17",
          "Statement": [
              {
                  "Sid": "BedrockFullAccess",
                  "Effect": "Allow",
                  "Action": [
                      "bedrock:*"
                  ],
                  "Resource": "*"
              }
          ]
      }
    )
  }
}


#Triggering the Lambda from SQS events
# Event source from SQS
resource "aws_lambda_event_source_mapping" "event_source_mapping_deleting" {
  event_source_arn                   = aws_sqs_queue.sqs_queue_delete.arn
  enabled                            = true #defines if mapping is enabled or not
  function_name                      = aws_lambda_function.sqs_lambda_function_deleting.arn
  batch_size                         = 10
  maximum_batching_window_in_seconds = 10
  scaling_config {
    maximum_concurrency = 10
  }
}


