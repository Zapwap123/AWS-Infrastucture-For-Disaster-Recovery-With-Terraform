resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  alarm_name          = "Primary-ALB-Unhealthy-Hosts"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 2
  alarm_description   = "Triggers failover if 2 or more unhealthy hosts"
  dimensions = {
    TargetGroup  = var.primary_alb_target_arn
    LoadBalancer = split("/", var.primary_alb_target_arn)[1]
  }
  treat_missing_data = "missing"
}

resource "aws_iam_role" "lambda_exec" {
  name = "DRTriggerLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "ecs_update_policy" {
  name = "UpdateDRService"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:UpdateService"
        ],
        Resource = "*",
        Effect   = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_update_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.ecs_update_policy.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "trigger_dr" {
  function_name    = "trigger-dr-failover"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.lambda_exec.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 10

  environment {
    variables = {
      CLUSTER_NAME = var.dr_cluster_name
      SERVICE_NAME = var.dr_service_name
      REGION       = var.dr_region
    }
  }
}

resource "aws_cloudwatch_event_rule" "alarm_trigger" {
  name = "trigger-dr-on-alarm"
  event_pattern = jsonencode({
    source        = ["aws.cloudwatch"],
    "detail-type" = ["CloudWatch Alarm State Change"],
    detail = {
      state = {
        value = ["ALARM"]
      },
      alarmName = [aws_cloudwatch_metric_alarm.alb_unhealthy_hosts.alarm_name]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.alarm_trigger.name
  target_id = "TriggerLambda"
  arn       = aws_lambda_function.trigger_dr.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger_dr.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.alarm_trigger.arn
}
