import boto3
import os
import json
from langchain.document_loaders import PyPDFLoader
from langchain.text_splitter import TokenTextSplitter, RecursiveCharacterTextSplitter
from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import argparse
from opensearchpy.helpers import bulk

# Initialize AWS clients
s3 = boto3.client('s3')
opensearchClient = boto3.client('opensearch')
ssm = boto3.client("ssm")

bedrock = boto3.client(
 service_name='bedrock',
 region_name='us-west-2',
 endpoint_url='https://bedrock.us-west-2.amazonaws.com'
)
    
import urllib.parse

def lambda_handler(event, context):
    try:
        for record in event['Records']:
            # Assuming the SQS message body contains the S3 event data
            s3_event = json.loads(record['body'])
            
            for j in s3_event['Records']:
                
                #print bedrock foundation models
                s= bedrock.list_foundation_models()
                print(s)
                
                bucketName = j['s3']['bucket']['name']
                fileKey = j['s3']['object']['key']
                fileKey = urllib.parse.unquote(fileKey)
                fileKey = fileKey.replace("+", " ")
                
                print(fileKey)

                # Retrieve PDF data from S3
                s3Response = s3.get_object(Bucket=bucketName, Key=fileKey)
                pdfData = s3Response['Body'].read()

                # Specify the temporary directory and PDF file path
                tempDir = '/tmp'
                tempPdfFilePath = os.path.join(tempDir, os.path.basename(fileKey))
                
                # Write the PDF data to the temporary PDF file
                with open(tempPdfFilePath, 'wb') as tempPdfFile:
                    tempPdfFile.write(pdfData)

                # Load the PDF data using PyPDFLoader (or other loaders)
                name, extension = os.path.splitext(tempPdfFilePath)

                if extension == '.pdf':
                    loader = PyPDFLoader(tempPdfFilePath)
                    data = loader.load()

                else:
                    print('Document format is not supported!')
                    
                print(data)
                
                #chunking the document
                textSplitternltk =  RecursiveCharacterTextSplitter(chunk_size=1500, chunk_overlap=200, length_function=len) 
                chunks = textSplitternltk.split_documents(data)
                
                print(chunks) 
                
                reference_name = fileKey.replace(".pdf", "") 
                # reference_name = reference_name.split()[-1]
                
                #convert chunks into the form of dictionary
                docs = []
                for idx, doc in enumerate(chunks):
                    document = {
                        'text': f"{reference_name} " + doc.page_content,
                        'document_name': doc.metadata['source'],
                        'page_number': doc.metadata['page']
                    }
                    docs.append(document)
                
                print(docs)
                
                #Get Domain Endpoint from SSM Parameter Store
                parameterDomainEndpoint = "/opensearch/domainEndpoint"
                responseDomainEndpoint = ssm.get_parameter(Name=parameterDomainEndpoint, WithDecryption=False)
                domainEndpoint = responseDomainEndpoint["Parameter"]["Value"]
                
                #Get Authorisation username and password from SSM Parameter Store
                #Username
                parameterUsername = "/opensearch/domainAuthUserName"
                responseUsername = ssm.get_parameter(Name=parameterUsername, WithDecryption=False)
                username = responseUsername["Parameter"]["Value"]
                
                #Password
                #Get Authorisation username and password from SSM Parameter Store
                parameterPassword = "/opensearch/domainAuthPassword"
                responsePassword = ssm.get_parameter(Name=parameterPassword, WithDecryption=False)
                password = responsePassword["Parameter"]["Value"]
                
                auth=(username, password)
                
                
                client = OpenSearch(
                    hosts = [{'host': domainEndpoint, 'port':443}],
                    http_auth = auth,
                    use_ssl = True,
                    verify_certs = True,
                    connection_class = RequestsHttpConnection,
                    timeout = 300
                )
                
                #settings for index of the OpenSearch
                settings = {
                    "settings": {
                        "index": {
                            "knn": True,
                            "knn.space_type" : "cosinesimil",
                            "knn.algo_param.ef_search": 100
                        }
                    }
                }
                
                # #Index Name
                # indexName = 'vector_store'
                
                #Get index name for opensearch from SSM parameter store
                parameterIndexName = "/opensearch/indexName"
                responseIndexName = ssm.get_parameter(Name=parameterIndexName, WithDecryption=False)
                indexName = responseIndexName["Parameter"]["Value"]
                
                #check if the index is created
                def checkIfIndexIsCreated(indexName):
                    exists = client.indices.exists(indexName)
                    return exists
                    
                exists = checkIfIndexIsCreated(indexName)
                
                if exists==False:
                    res = client.indices.create(index=indexName, body=settings, ignore=[400])
                    client.indices.put_mapping(
                        index=indexName,
                        body={
                            "properties": {
                                "text": {
                                    "type": "text"
                                },
                                "document_name": {
                                    "type": "text"
                                },
                                "page_number": {
                                    "type": "text"
                                },
                                "vector_field": {
                                    "type": "knn_vector",
                                    "dimension": 1536
                                }
                            }
                        }
                    )
                elif exists==True:
                    print("index exists.")
                
                # # ##for testing delete the created index
                # responseDelete = client.indices.delete(index=indexName)
                
                #embedding creation
                for doc in docs:
                    payload = {"inputText": doc['text']}
                    body = json.dumps(payload)
                    modelId = "amazon.titan-embed-g1-text-02"
                    accept = "application/json"
                    contentType = "application/json"
                
                    response = bedrock.invoke_model(
                        body=body, modelId=modelId, accept=accept, contentType=contentType
                    )
                    response_body = json.loads(response.get("body").read())
                
                    embedding = response_body.get("embedding")
                    doc['vector_field'] = embedding
                    doc['_index'] = indexName

                success, failed = bulk(client, docs)
                print(success)
                
    except Exception as exception:
        print(exception)
        