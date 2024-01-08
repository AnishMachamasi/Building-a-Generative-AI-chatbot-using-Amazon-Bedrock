resource "aws_ssm_parameter" "opensearch-domainEndpoint" {
  name = "/opensearch/domainEndpoint"  #Donot change parameter name. Only change variables in c2-varaibles.tf
  type = "String"
  value = aws_opensearch_domain.OpenSearch-VectorStore.endpoint
}

resource "aws_ssm_parameter" "master_user_name_param" {
  name = "/opensearch/domainAuthUserName"  #Donot change parameter name. Only change variables in c2-varaibles.tf
  type = "String"
  value = var.OpenSearchMasterUserName
}

resource "aws_ssm_parameter" "master_user_password_param" {
  name = "/opensearch/domainAuthPassword"  #Donot change parameter name. Only change variables in c2-varaibles.tf
  type = "String"
  value = var.OpenSearchMasterUserPassword
}

resource "aws_ssm_parameter" "OpenSeach_index_name" {
  name = "/opensearch/indexName"  #Donot change parameter name. Only change variables in c2-varaibles.tf
  type = "String"
  value = var.OpenSearchIndexName
}

# resource "aws_ssm_parameter" "Embedding_Endpoint_Name" {
#   name = "/sagemaker/embeddingEndpoint"  #Donot change parameter name. Only change variables in c2-varaibles.tf
#   type = "String"
#   value = var.SagemakerEmbeddingEndpoint
# }

resource "aws_ssm_parameter" "maximum_number_of_file_indexed" {
  name = "/lambda/MaximumNumberofFileIndexed"  #Donot change parameter name. Only change variables in c2-varaibles.tf
  type = "String"
  value = var.maximumNumberOfDocumentIndexed
}

resource "aws_ssm_parameter" "number_of_document_to_be_retrieved_from_opensearch" {
  name = "/lambda/NumberOfDocumentToBeRetrieved"  #Donot change parameter name. Only change variables in c2-varaibles.tf
  type = "String"
  value = var.numberOfLambdaRetreiving
}

resource "aws_ssm_parameter" "APIGatewayPOSTAPI" {
  name = "/APIGateway/POSTAPI"
  type = "String"
  value = aws_api_gateway_stage.stage.invoke_url
}

resource "aws_ssm_parameter" "APIGatewayPOSTAPIResource" {
  name = "/APIGateway/POSTAPIResource"
  type = "String"
  value = aws_api_gateway_resource.resource.path_part
}

