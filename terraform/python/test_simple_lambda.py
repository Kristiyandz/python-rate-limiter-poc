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
        'message': "Hello from Lambda!"
    }
    assert result == json.dumps(expected)
