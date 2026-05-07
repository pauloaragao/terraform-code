locals {
  workspace_suffix      = lower(terraform.workspace)
  lambda_function_name  = "${var.function_name}-${local.workspace_suffix}"
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${local.lambda_function_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_lambda_function" "main" {
  function_name    = local.lambda_function_name
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "python3.12"
  handler          = "handler.lambda_handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  memory_size      = 128
  timeout          = 10
  architectures    = ["arm64"]

  environment {
    variables = {
      ENV = "dev"
    }
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 7

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}