import boto3
import os
import json
from opensearchpy import OpenSearch, RequestsHttpConnection, AWSV4SignerAuth
import urllib.parse

opensearchClient = boto3.client('opensearch')
ssm = boto3.client("ssm")

def lambda_handler(event, context):
    for record in event['Records']:
        # Assuming the SQS message body contains the S3 event data
        s3_event = json.loads(record['body'])
        
        for j in s3_event['Records']:
            bucketName = j['s3']['bucket']['name']
            fileKey = j['s3']['object']['key']
            fileKey = urllib.parse.unquote(fileKey)
            fileKey = fileKey.replace("+", " ")
            tempDir = '/tmp'
            tempPdfFilePath = os.path.join(tempDir, os.path.basename(fileKey))
            
            print(tempPdfFilePath)
            
            # Initialize OpenSearch client
            #uploading page_content and embedding to opensearch
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
            
            #Get index name for opensearch from SSM parameter store
            parameterIndexName = "/opensearch/indexName"
            responseIndexName = ssm.get_parameter(Name=parameterIndexName, WithDecryption=False)
            indexName = responseIndexName["Parameter"]["Value"]
            
            #delete certain document
            response_search = client.search(
            body = {
                'size' : 1100,
                'query': {
                    'match_all' : {}
                }
                },
            index = indexName
            )
            
            docu_list = []
            for i in range(len(response_search['hits']['hits'])):
                docu_list.append(response_search['hits']['hits'][i]['_source']['document_name']) 
            
            print(docu_list)
            for doc_name in docu_list:      # this is the case for updating the chunks that are linked to many other pdfs
                
                print(doc_name)
                if doc_name == tempPdfFilePath:
                    print(docu_list)
                    print('I am same.')
                    index = docu_list.index(doc_name)
                    print(index)
                    _id = response_search['hits']['hits'][index]['_id'] 
                    print('I am id', _id)
                    docu_list[index] = _id
                    client.delete(
                        index = indexName,
                        id = _id
                        )
    return {
        'statusCode': 200,
        'body': json.dumps('Deleted filename extracted!')
    }