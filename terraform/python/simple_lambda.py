import json


def handler(event, context):
    response = {
        "statusCode": 200,
        "headers": {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps({
            'message': "Hello from Lambda!"
        }),
        "isBase64Encoded": False
    }
    return response
