import sys
import os
import boto3
from langchain.embeddings import BedrockEmbeddings
from langchain.vectorstores import OpenSearchVectorSearch
from langchain.chains import RetrievalQA
from langchain.memory import ConversationBufferMemory
from langchain.prompts import PromptTemplate
from langchain.llms.bedrock import Bedrock
ssm = boto3.client("ssm")
import json

def get_bedrock_client():
    bedrock = boto3.client(
     service_name='bedrock',
     region_name='us-west-2',
     endpoint_url='https://bedrock.us-west-2.amazonaws.com'
    )
    return bedrock

def create_langchain_vector_embedding_using_bedrock(bedrock_client):
    bedrock_embeddings_client = BedrockEmbeddings(
        client=bedrock_client,
        model_id="amazon.titan-embed-g1-text-02")
    return bedrock_embeddings_client
    

def create_opensearch_vector_search_client(indexName, auth, bedrock_embeddings_client, opensearch_endpoint, _is_aoss=False):
    docsearch = OpenSearchVectorSearch(
        index_name=indexName,
        embedding_function=bedrock_embeddings_client,
        opensearch_url=f"https://{opensearch_endpoint}",
        http_auth=auth,
        is_aoss=_is_aoss
    )
    return docsearch


def create_bedrock_llm(bedrock_client):
    bedrock_llm = Bedrock(
        model_id="ai21.j2-mid", 
        client=bedrock_client,
        model_kwargs={'temperature': 0.5, 'maxTokens':8191, "topP":0.8}
        )
    return bedrock_llm
    

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        question = body["question"]
        
        # vars
        region = "us-west-2"
        #Get index name for opensearch from SSM parameter store
        parameterIndexName = "/opensearch/indexName"
        responseIndexName = ssm.get_parameter(Name=parameterIndexName, WithDecryption=False)
        indexName = responseIndexName["Parameter"]["Value"] 
        
        # Creating all clients for chain
        # account_id = iam.get_account_id()
        bedrock_client = get_bedrock_client()
        bedrock_llm = create_bedrock_llm(bedrock_client)
        
        bedrock_embeddings_client = create_langchain_vector_embedding_using_bedrock(bedrock_client)
        
        parameterDomainEndpoint = "/opensearch/domainEndpoint"
        responseDomainEndpoint = ssm.get_parameter(Name=parameterDomainEndpoint, WithDecryption=False)
        opensearch_endpoint = responseDomainEndpoint["Parameter"]["Value"]
        
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
        
        auth = (username, password)
        
        opensearch_vector_search_client = create_opensearch_vector_search_client(indexName, auth, bedrock_embeddings_client, opensearch_endpoint)
        
        # LangChain prompt template
        question = question
        
        prompt_template = """Use the following pieces of context to answer the question at the end. If you don't know the answer, just say that you don't know, don't try to make up an answer. don't include harmful content

        {context}

        Question: {question}
        Answer:"""
        PROMPT = PromptTemplate(
            template=prompt_template, input_variables=["context", "question"]
        )
        
        qa = RetrievalQA.from_chain_type(llm=bedrock_llm, 
                                         chain_type="stuff", 
                                         retriever=opensearch_vector_search_client.as_retriever(), #search_type = "similarity", search_kwargs = { "k": 23 }
                                         return_source_documents=True,
                                         chain_type_kwargs={"prompt": PROMPT, "verbose": False}, 
                                         verbose=True) 
    
        res = qa(question, return_only_outputs=False)
        
        print(res)
        document_source = []
        for d in res['source_documents']:
            document_name = d.metadata['document_name'].replace("/tmp/", "")
            page_number = d.metadata['page_number']
            page_number = int(page_number) + 1
            documentSource = f"{document_name}, PageNo. {page_number}"
            document_source.append(documentSource)
            print(document_source)
            
        result = {
            "query": res['query'],
            "answer": res['result'],
            "document Source": document_source
        }
        
        response = {
            'statusCode': 200,
            'body': json.dumps(result)
        }
        
    except json.JSONDecodeError:
        response = {
            "statusCode": 400,
            "body": json.dumps({"message": "Invalid Json"})
        }
    
    return response
