import boto3

def lambda_handler(event, context):
    ecs = boto3.client('ecs', region_name='eu-west-2')  # DR region

    response = ecs.update_service(
        cluster='ECS-LAMP-Cluster-DR',
        service='ECS-LAMP-Cluster-DR-service',
        desiredCount=2
    )

    return {
        'statusCode': 200,
        'body': 'DR ECS service scaled to 2'
    }
