import pytest
import json
from simple_lambda import handler


@pytest.fixture
def event():
    return None


@pytest.fixture
def context():
    return None


def test_function(event, context):
    result = handler(event, context)

    expected = {
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
    assert result == expected
