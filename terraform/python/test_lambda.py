import json


async def handler(event, context):
    response = {
        "statusCode": 200,
        "body": "Hello from Python Lambda!"
    }
    return json.dumps(response)
