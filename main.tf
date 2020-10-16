provider "aws" {
}

data "aws_route53_zone" "public" {
  name         = var.public_subdomain
  private_zone = false
}

module "acm" {
  source             = "terraform-aws-modules/acm/aws"
  version            = "2.11.0"
  create_certificate = true
  domain_name        = var.public_subdomain
  zone_id            = data.aws_route53_zone.public.zone_id
  subject_alternative_names = [
    "java.${var.public_subdomain}",
    "api.${var.public_subdomain}",
    "*.${var.public_subdomain}"
  ]
  tags = {
    Name = var.public_subdomain
  }
}

resource "aws_lambda_function" "example" {
  function_name = "ServerlessExample"

  s3_bucket = var.s3_bucket
  s3_key    = "bot/build.zip"

  handler = "src/handlers/bot-handler.handler"
  runtime = "nodejs10.x"

  role = aws_iam_role.iam_role_lambda_execution.arn

  environment {
    variables = {
      TELEGRAM_BOT_KEY = var.telegram_token
      PIXABAYAPI       = var.pixabay_token
    }
  }
}

data "aws_iam_policy_document" "lambda_sts_policy" {
  version = "2012-10-17"
  statement {
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "iam_role_lambda_execution" {
  assume_role_policy = data.aws_iam_policy_document.lambda_sts_policy.json
}

data "aws_iam_policy_document" "iam_lambda_execution_role_policy_document" {
  version = "2012-10-17"
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy" "iam_role_lambda_execution_policy" {
  name   = "iam_lambda_execution_role_policy"
  role   = aws_iam_role.iam_role_lambda_execution.id
  policy = data.aws_iam_policy_document.iam_lambda_execution_role_policy_document.json
}

resource "aws_cloudwatch_log_group" "custom_authorizer_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.example.function_name}"
  retention_in_days = 1
}


resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
  //  endpoint_configuration {
  //    types = ["REGIONAL"]
  //  }
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_rest_api.example.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_deployment" "example" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]
  description = "Updated at ${timestamp()}"
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = var.environment
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.example.execution_arn}/*/*"
}

output "base_url" {
  description = "Endpoint API calls"
  value       = aws_api_gateway_deployment.example.invoke_url
}

resource "aws_api_gateway_domain_name" "example" {
  domain_name     = "api.${var.public_subdomain}"
  certificate_arn = module.acm.this_acm_certificate_arn
  //  endpoint_configuration {
  //    types = ["REGIONAL"]
  //  }
}

resource "aws_api_gateway_base_path_mapping" "custom_domain" {
  api_id      = aws_api_gateway_rest_api.example.id
  stage_name  = var.environment
  domain_name = aws_api_gateway_domain_name.example.domain_name
}

resource "aws_route53_record" "region_one" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = aws_api_gateway_domain_name.example.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.example.cloudfront_domain_name
    zone_id                = aws_api_gateway_domain_name.example.cloudfront_zone_id
    evaluate_target_health = true
  }
}
