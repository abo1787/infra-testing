#build ALB to front the service.  

resource "aws_vpc" "cardinal-test-vpc" {
  cidr_block  = var.vpc_cidr_block
  tags        = local.default-tags
}

resource "aws_internet_gateway" "cardinal-test-igw" {
  vpc_id  = aws_vpc.cardinal-test-vpc.id
  tags    = local.default-tags
}

resource "aws_route" "cardinal-ec2-igw-route" {
  route_table_id         = aws_vpc.cardinal-test-vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.cardinal-test-igw.id
}

resource "aws_db_subnet_group" "cardinal-rds-sub-grp" {
  name        = "${local.app_full_name}-rds-subnet-grp"
  subnet_ids  = [aws_subnet.cardinal-rds-subnet-1.id, aws_subnet.cardinal-rds-subnet-2.id]
  tags        = local.default-tags
}

#Egress here is technically not used as AWS does this by default, however I like it being in the template so that it's there to manipulate later.  Long term Egress and Ingress should be locked. 
#As this is my RDS SG, I've allowed ingress only from the EC2 instance we're creating below. 
resource "aws_security_group" "cardinal-rds-sg" {
  name        = "${local.app_full_name}-rds-sg"
  description = "Allow inbound connections to RDS instance"
  vpc_id      = aws_vpc.cardinal-test-vpc.id
  tags        = local.default-tags

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.cardinal-app-instance.private_ip}/32"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

#Same egress note here as in RDS SG note above.
resource "aws_security_group" "cardinal-app-sg" {
  name        = "${local.app_full_name}-app-sg"
  description = "Allow inbound connections to EC2 instance"
  vpc_id      = aws_vpc.cardinal-test-vpc.id
  tags        = local.default-tags
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["71.77.164.150/32"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "cardinal-rds-subnet-1" {
  vpc_id                  = aws_vpc.cardinal-test-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}${element(var.aws_azs, 0)}"
  tags                    = local.default-tags
}

resource "aws_subnet" "cardinal-rds-subnet-2" {
  vpc_id                  = aws_vpc.cardinal-test-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}${element(var.aws_azs, 1)}"
  tags                    = local.default-tags
}

resource "aws_subnet" "cardinal-ec2-subnet" {
  vpc_id                  = aws_vpc.cardinal-test-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "${var.aws_region}${element(var.aws_azs, 0)}"
  tags                    = local.default-tags
}

resource "aws_subnet" "cardinal-igw-subnet" {
  vpc_id                  = aws_vpc.cardinal-test-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "${var.aws_region}${element(var.aws_azs, 0)}"
  tags                    = local.default-tags
}

resource "aws_subnet" "cardinal-igw-subnet-backup" {
  vpc_id                  = aws_vpc.cardinal-test-vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "${var.aws_region}${element(var.aws_azs, 1)}"
  tags                    = local.default-tags
}

resource "aws_lb" "cardinal-app-alb" {
  name                              = "${local.app_full_name}-alb"
  internal                          = false
  load_balancer_type                = "application"
  security_groups                   = [aws_security_group.cardinal-app-sg.id]
  enable_deletion_protection        = false
  enable_http2                      = true
  enable_cross_zone_load_balancing  = true
  subnets                           = [aws_subnet.cardinal-igw-subnet.id, aws_subnet.cardinal-igw-subnet-backup.id] 
  tags                              = local.default-tags
}

resource "aws_lb_target_group" "cardinal-app-tg" {
  name        = "${local.app_full_name}-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.cardinal-test-vpc.id
  tags        = local.default-tags
}

resource "aws_lb_listener" "cardinal-app-listener" {
  load_balancer_arn = aws_lb.cardinal-app-alb.arn
  port              = 80
  protocol          = "HTTP"
  tags              = local.default-tags

  default_action {
    target_group_arn = aws_lb_target_group.cardinal-app-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group_attachment" "cardinal-app-tg-attachment" {
  target_group_arn = aws_lb_target_group.cardinal-app-tg.arn
  target_id        = aws_instance.cardinal-app-instance.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.cardinal-test-vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags         = local.default-tags
}