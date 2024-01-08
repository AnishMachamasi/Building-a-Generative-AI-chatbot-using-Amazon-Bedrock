#Input Variabales

#Enter the number of documents to be retrieved
variable "numberOfLambdaRetreiving" {
  description = "number of documents to be retrieved from the opensearch"
  default = 7
}

#AWS Region
variable "aws_region" {
    description = "AWS Region in which the resources to be created"
    type = string
    default = "aws_region"
}



#AWS Account Number
variable "AccountNumber" {
    description = "account number to AWS"
    default = "your_account_id"
}



#S3 Source Bucket
variable "S3Bucketsource" {
    description = "source bucket to store upload files"
    default = "anish-s3-sqs-lambda-bucketsources"
}



#Simple Queue Service(SQS)
#s3 put event/ uploading embedding to opensearch
variable "sqsS3PutEvent" {
    description = "SQS queue that have s3 upload file events in the queue"
    default = "SQSS3PutEvent"
}
#s3 delete event/ updating or deleting metadata in OpenSearch
variable "sqsS3DeleteEvent" {
  description = "sqs queue name for updating the metadata in OpenSearch"
  default = "SQSS3DeleteEvent"
}


#DeadLetterQueue
variable "dlq_name_dead_letter_queue" {
  description = "name for the dead letter queue"
  default = "UpdateDeadLetterQueue"
}



#Lambda Functions
#Lambda Function for Uploading Embedding
variable "lambdaUploadEmbedding" {
    description = "lambda function which embedd the page content and upload to OpenSearch"
    default = "LambdaForUploading"
}
#Lambda Function Role for Uploading Embedding
variable "lambdaUploadEmbeddingRole" {
    description = "role name for Lambda function"
    default = "LambdaForUploadingRole"
}



#Lambda Function for Retreiving Embedding
variable "lambdaRetreiveEmbedding" {
    description = "lambda function to retreive embedding from the OpenSearch"
    default = "LambdaForRetrieving"
}
#Lambda Function Role for Retreiving Embedding
variable "lambdaRetreiveEmbeddingRole" {
  description = "role name for retreiving data from opensearch"
  default = "LambdaForRetrievingRole"
}



#Lambda function for deleting and updating metadata in OpenSearch
variable "lambdaDeleteEmbedding" {
  description = "lambda function to update or delete metadata in document or its metadata"
  default = "LambdaForDeleting"
}
#Lambda Function Role for Deleting Embedding
variable "lambdaDeleteEmbeddingRole" {
  description = "role name for deleting metadata from opensearch"
  default = "LambdaForDeletingRole"
}



# Lambda layer
variable "lambdaLayerName" {
  description = "name for lambda layer"
  default = "SQS-Lambda-OpenSearchLayer"
}



#OpenSearch Domain
variable "OpenSearchVectorStore" {
    description = "OpenSearch Implementation as a vector store"
    default = "opensearchvectorstore"
}
variable "OpenSearchEngineVersion" {
  description = "OpenSearch Engine Version"
  default = "OpenSearch_2.7"
}
variable "OpenSearchMasterUserName" {
    description = "OpenSearch Master User Name"
    default = "anishmachamasi"
}
variable "OpenSearchMasterUserPassword" {
    description = "OpenSearch Master User Password"
    default = "Aa@123456789"
}
variable "OpenSearchIndexName" {
  description = "name of the index created inside the OpenSearch"
  default = "vector-store"
}
variable "EBSVolumeSize" {
  description = "Size of the EBS volume for the OpenSearch"
  default = "20"
}
#This instance type is for testing. For deployment use another instance.
variable "OpenSearchInstanceType" {
  description = "Instance Type for OpenSearch"
  default = "t3.medium.search"
}
#Number of Instance to set to 3 for 3 availability zone
variable "NumberOfInstance" {
  description = "Number of Instance for OpenSearch"
  default = "1"
}



#Sagemaker Embedding Endpoint
variable "SagemakerEmbeddingEndpoint" {
    description = "sagemaker embedding endpoint for model mini-lm-v2"
    default = "myall-MiniLM-L6-v2endpoint"
}
variable "SagemakerEmbeddingEndpointConfiguration" {
  description = "Configuration for sagemaker embedding endpoint"
  default = "jumpstart-dft-hf-textembedding-all-minilm-l6-v2"
}
variable "SagemakerEmbeddingModel" {
  description = "Embedding model for embedding endpoint"
  default = "huggingface-textembedding-all-MiniLM-L6-v2"
}
variable "SagemakerEmbeddingModelRoleName" {
  description = "Role name for Embedding model"
  default = "sagemaker-role"
}
variable "SagemakerEmbeddingModelInstance" {
  description = "instance for sagemaker embedding model instance"
  default = "ml.c5.large"
}
variable "MaxConcurrentInvocation" {
  description = "maximum number of concurrent invocations for serverless endpoint"
  default = 2 ##Available Quota is only 10
}
variable "MemoryForServerlessEndpoint" {
  description = "memory size of serverless endpoint"
  default = 3072
}


#api gateway
variable "APIGateWayName" {
  description = "name of the api gateway"
  default = "APIGatewayRetreiving"
}
variable "ApiStageName" {
  description = "stage name for api gateway"
  default = "PostStage"
}
  


#maximum number of document which have been indexed into OpenSearch
variable "maximumNumberOfDocumentIndexed" {
  description = "Enter the maximum number of document to be deleted"
  default = 1000
}



