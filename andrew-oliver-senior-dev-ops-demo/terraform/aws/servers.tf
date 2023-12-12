#This should go in a secrets vault much like the other bits, but being public and for this test, I'm going ahead and putting it here referencing a local file.  
resource "aws_key_pair" "deploy-key" {
  key_name    = "deploy-key"
  public_key  = file(var.public_key)
  tags        = local.default-tags
}

resource "aws_iam_role" "cardinal-ec2-role" {
  name               = "${local.app_full_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags               = local.default-tags
}

resource "aws_iam_role_policy_attachment" "cardinal-ec2-role-attachment" {
  role       = aws_iam_role.cardinal-ec2-role.name
  policy_arn = aws_iam_policy.cardinal-storage-bucket-policy.arn
}

resource "aws_iam_instance_profile" "cardinal-ec2-instance-profile" {
  name = "allow-ec2-s3-access"
  role = aws_iam_role.cardinal-ec2-role.name
}

resource "aws_instance" "cardinal-app-instance" {
  ami                         = var.aws_ami_id
  instance_type               = var.ec2_instance_size
  vpc_security_group_ids      = [aws_security_group.cardinal-app-sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cardinal-ec2-subnet.id
  depends_on                  = [aws_s3_bucket.cardinal-storage-bucket, aws_internet_gateway.cardinal-test-igw, aws_route.cardinal-ec2-igw-route]
  key_name                    = aws_key_pair.deploy-key.key_name
  iam_instance_profile        = aws_iam_instance_profile.cardinal-ec2-instance-profile.id
  tags                        = local.default-tags
  connection {
    type        = "ssh"
    user        = var.remote_user
    private_key = file(var.private_key)
    host        = self.public_ip
  }
  
#install docker-engine, and pull the container then start it
  provisioner "remote-exec" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y docker",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo chkconfig docker on",
      "sudo dnf install -y postgresql15"
    ]
  }
}