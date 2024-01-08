resource "aws_s3_bucket" "s3_bucket_source" {
  bucket = var.S3Bucketsource
  tags = {
    Name        = "s3-sqs-lambda",
    Environment = "Dev"
  }
}

#Add notification configuration to SQS Queue
resource "aws_s3_bucket_notification" "s3_bucket_notification_put" {
  bucket = aws_s3_bucket.s3_bucket_source.id
  queue {
    queue_arn     = aws_sqs_queue.sqs_queue_update.arn
    events        = ["s3:ObjectCreated:*"]
  }

    queue {
    queue_arn     = aws_sqs_queue.sqs_queue_delete.arn
    events        = ["s3:ObjectRemoved:*"]
  }
}

