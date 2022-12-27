resource "aws_api_gateway_account" "demo" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

resource "aws_iam_role" "cloudwatch" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "default"
  role = aws_iam_role.cloudwatch.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_api_gateway_rest_api" "example" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })

  api_key_source = "HEADER"

  name = "example"
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = "dev"
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.example.id
}

resource "aws_api_gateway_deployment" "example" {
  rest_api_id = aws_api_gateway_rest_api.example.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.example.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.example.id}/development"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "foo" {
  name           = "SampleLogStream1234"
  log_group_name = aws_cloudwatch_log_group.example.name
}

resource "aws_api_gateway_stage" "development" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "development"
  depends_on = [
    aws_cloudwatch_log_group.example
  ]
}

resource "aws_api_gateway_stage" "production" {
  deployment_id = aws_api_gateway_deployment.example.id
  rest_api_id   = aws_api_gateway_rest_api.example.id
  stage_name    = "production"
}

resource "aws_api_gateway_usage_plan" "example" {
  name         = "my-usage-plan"
  description  = "my description"
  product_code = "MYCODE"

  api_stages {
    api_id = aws_api_gateway_rest_api.example.id
    stage  = aws_api_gateway_stage.development.stage_name
    throttle {
      path       = "/path1/GET"
      rate_limit = 2
    }
  }

  api_stages {
    api_id = aws_api_gateway_rest_api.example.id
    stage  = aws_api_gateway_stage.production.stage_name
  }

  quota_settings {
    limit  = 3
    offset = 0
    period = "DAY"
  }



  throttle_settings {
    burst_limit = 5
    rate_limit  = 5
  }
}

resource "aws_api_gateway_api_key" "mykey" {
  name = "demo"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.mykey.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.example.id
}

resource "aws_api_gateway_method_settings" "settings" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = aws_api_gateway_stage.development.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    metrics_enabled    = true
  }
}
