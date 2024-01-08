#Creating standard queue
resource "aws_sqs_queue" "sqs_queue_update" {
  name                       = var.sqsS3PutEvent
  delay_seconds              = 0
  visibility_timeout_seconds = 900  #15minutes
  max_message_size           = 262144 #256KB
  message_retention_seconds  = 3600 #1hour
  receive_wait_time_seconds  = 20   #Long polling
  sqs_managed_sse_enabled    = true
  redrive_policy = jsonencode({

    deadLetterTargetArn = aws_sqs_queue.dlq_queue_update.arn
    maxReceiveCount     = 3 #retry 5 times before sending to dlq
    
  })
}

resource "aws_sqs_queue_policy" "sqs_queue_policy_updating" {
  queue_url = aws_sqs_queue.sqs_queue_update.id

  policy = jsonencode({
  "Version": "2012-10-17",
  "Id": "Policy1692780120633",
  "Statement": [
    {
      "Sid": "Stmt1692780117750",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:*",
      "Resource": "arn:aws:sqs:${var.aws_region}:${var.AccountNumber}:${var.sqsS3PutEvent}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "arn:aws:s3:::${var.S3Bucketsource}"
        }
      }
    }
  ]
})
}
