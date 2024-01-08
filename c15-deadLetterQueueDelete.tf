#Allowing SendMessage access to dlq sqs from s3
data "aws_iam_policy_document" "dlq-queue-delete" {
  statement {
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:putDeadLetterQueue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.s3_bucket_source.arn]
    }
  }
}

#Creating dead letter queue
resource "aws_sqs_queue" "dlq_queue_delete" {
  name   = var.dlq_name_dead_letter_queue
  delay_seconds              = 0
  visibility_timeout_seconds = 900  #15minutes
  max_message_size           = 262144 #256KB
  message_retention_seconds  = 3600 #1hour
  receive_wait_time_seconds  = 20   #Long polling
  sqs_managed_sse_enabled    = true
  policy = data.aws_iam_policy_document.dlq-queue-delete.json
}

# resource "aws_sqs_queue_redrive_allow_policy" "redrive_policy_delete" {
#   queue_url = aws_sqs_queue.dlq_queue_delete.id
#   redrive_allow_policy = jsonencode({
#     redrivePermission = "byQueue",
#     sourceQueueArns   = [aws_sqs_queue.sqs_queue_delete.arn]
#   })
# }


# #Cloudwatch alarm for the update dead letter queue
# resource "aws_cloudwatch_metric_alarm" "alarm_update" {
#   alarm_name = "DeadLetterQueueAlarm"
#   alarm_description = "Some Files are failed to delete from OpenSearch."
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods = 1
#   metric_name = "ApproximateNumberOfMessagesVisible"
#   namespace = "AWS/SQS"
#   period = 300
#   statistic = "SampleCount"
#   threshold = 1
#   treat_missing_data = "notBreaching"
#   alarm_actions = [aws_sns_topic.sns_dlq_notification_delete.arn]
#   ok_actions = [aws_sns_topic.sns_dlq_notification_delete.arn]
#   dimensions = {
#     "QueueName" = aws_sqs_queue.sqs_queue_update.name
#   }
# }


# #Simple Notification Service to send email to notify about the failed events
# resource "aws_sns_topic" "sns_dlq_notification_delete" {
#   name = "sns_dlq_notification_update"
# }

# resource "aws_sns_topic_subscription" "sns_test_subscription_delete" {
#   topic_arn = aws_sns_topic.sns_dlq_notification_delete.arn
#   protocol = "email"
#   endpoint = "anishmachamasi2262@gmail.com"
# }