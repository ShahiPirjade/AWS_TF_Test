#BOTO3 OFFICIAL AWS DOCUMENTATIOn LINK - https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/sns/client/publish.html
import boto3
sns = boto3.client('sns', region_name='us-east-2') 
response = sns.publish(
    TopicArn='arn:aws:sns:us-east-2:616904086648:aws-sns-topic-case1',
    #TargetArn='string',
    #PhoneNumber='+1 619-877-5178',
    Message='Hi Team, This is Shahisth Pirjade who enjoys coding and have completed the task 2 successfully, by sending the message from boto3 python script which sends a message to the SNS group subscribers',
    Subject='Task2 Update',
    #MessageStructure='String',
    MessageAttributes={
        'eventType': {
            'DataType': 'String',
            'StringValue': 'task_update'
        }
    },
    #MessageDeduplicationId='string',
    #MessageGroupId='string'
)