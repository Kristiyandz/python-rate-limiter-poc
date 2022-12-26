import json


def handler(event, context):
    response = {
        'message': "Hello from Lambda!"
    }
    return json.dumps(response)
