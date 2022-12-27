
data "archive_file" "my_test_lambda_archive" {
  type        = "zip"
  source_file = "./python/simple_lambda.py"
  output_path = "lambda/dist/simple_lambda.zip"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_role_test_python_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "LambdaBasicRole",
        Effect    = "Allow",
        Principal = { Service = "lambda.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_lambda_function" "my_test_lambda" {
  function_name    = var.function_name
  filename         = data.archive_file.my_test_lambda_archive.output_path
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "simple_lambda.handler"
  source_code_hash = filebase64sha256(data.archive_file.my_test_lambda_archive.output_path)

  # Lambda Runtimes can be found here: https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html
  runtime = "python3.9"
  timeout = "30"
  # memory_size = local.lambda_memory

  # environment {
  #   variables = {
  #     "EXAMPLE_SECRET" = "${var.example_secret}"
  #   }
  # }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:eu-west-2:580549185469:${aws_api_gateway_rest_api.example.id}/*/GET${aws_api_gateway_resource.resource.path}"
}

