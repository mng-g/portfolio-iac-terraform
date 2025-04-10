resource "aws_s3_bucket" "cloudtrail" {
  bucket = "my-terraform-cloudtrail-logs-${var.environment}"

  tags = merge(var.tags, {
    Name        = "cloudtrail-logs-${var.environment}",
    Environment = var.environment
  })
}

# resource "aws_s3_bucket_acl" "cloudtrail_acl" {
#   bucket = aws_s3_bucket.cloudtrail.id
#   acl    = "private"
# }

resource "aws_s3_bucket_versioning" "cloudtrail_versioning" {
  bucket = aws_s3_bucket.cloudtrail.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action    = "s3:GetBucketAcl",
        Resource  = aws_s3_bucket.cloudtrail.arn
      },
      {
        Sid       = "AWSCloudTrailWrite",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/aws/cloudtrail/my-cloudtrail-${var.environment}"
  retention_in_days = 30   # Adjust retention as needed

  tags = merge(var.tags, {
    Name        = "cloudtrail-log-group-${var.environment}",
    Environment = var.environment
  })
}

resource "aws_iam_role" "cloudtrail_cloudwatch_role" {
  name = "CloudTrail_CloudWatchLogs_Role_${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudtrail_cloudwatch_policy" {
  name = "CloudTrail_CloudWatchLogs_Policy_${var.environment}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudtrail_cloudwatch_attach" {
  role       = aws_iam_role.cloudtrail_cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudtrail_cloudwatch_policy.arn
}

resource "aws_cloudtrail" "this" {
  name                          = "my-cloudtrail-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true

  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_role.arn

  tags = merge(var.tags, {
    Name        = "cloudtrail-${var.environment}",
    Environment = var.environment
  })

  depends_on = [aws_iam_role_policy_attachment.cloudtrail_cloudwatch_attach, aws_s3_bucket_policy.cloudtrail_policy]
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "HighCPUAlarm-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "Alarm when EC2 CPU exceeds 80% for 2 consecutive periods"
  
  dimensions = {
    InstanceId = var.instance_id  # Adjust this to match the output name from your EC2 module
  }

  tags = merge(var.tags, { Environment = var.environment })
}

