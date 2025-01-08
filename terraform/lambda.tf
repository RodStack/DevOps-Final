# IAM Role para Lambda
resource "aws_iam_role" "lambda_role" {
  name = "lambda_processor_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Políticas para el rol de Lambda
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_processor_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.main.arn
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.alerts.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Función Lambda
resource "aws_lambda_function" "processor" {
  filename         = "lambda_function.zip"
  function_name    = "message-processor"
  role            = aws_iam_role.lambda_role.arn
  handler         = "function.handler"
  runtime         = "nodejs18.x"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.alerts.arn
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_policy
  ]
}

# Trigger de SQS para Lambda
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.main.arn
  function_name    = aws_lambda_function.processor.function_name
  batch_size       = 1
  enabled          = true
}