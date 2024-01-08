resource "aws_s3_object" "layer_zip" {
  bucket = aws_s3_bucket.s3_bucket_source.id
  key    = "layer.zip"
  source = "./layer.zip"
}

resource "aws_lambda_layer_version" "layer" {
  s3_bucket     = aws_s3_bucket.s3_bucket_source.id
  s3_key        = aws_s3_object.layer_zip.key
  layer_name    = var.lambdaLayerName
  compatible_runtimes = ["python3.8"]  # Update with the runtime you are using
}
