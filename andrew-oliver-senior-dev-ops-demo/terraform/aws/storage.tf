resource "aws_s3_bucket" "cardinal-storage-bucket" {
  bucket  = local.app_bucket_name
  tags    = local.default-tags
}

resource "aws_iam_policy" "cardinal-storage-bucket-policy" {
  name        = "${local.app_full_name}-bucket-policy"
  path        = "/"
  description = "Allow "
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Principal": {},
			"Effect": "Allow",
			"Action": [
				"s3:Get*",
				"s3:List*"
			],
			"Resource": [
				"arn:aws:s3:::test-bucket-abo1787"
			]
		}
	]
})
}
