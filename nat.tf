resource "aws_autoscaling_group" "nat_asg_0" {
  name                = "nat-0"
  vpc_zone_identifier = [module.vpc.public_subnets[0]]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.nat_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nat-0"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nat_asg_1" {
  name                = "nat-1"
  vpc_zone_identifier = [module.vpc.public_subnets[1]]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.nat_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nat-1"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "nat_asg_2" {
  name                = "nat-2"
  vpc_zone_identifier = [module.vpc.public_subnets[2]]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.nat_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "nat-2"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "nat_launch_template" {
  name_prefix            = "nat"
  image_id               = data.aws_ami.nat_instance_ami.id
  instance_type          = "t2.micro"
  key_name               = "gurpal-2020"
  vpc_security_group_ids = [aws_security_group.nat.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.nat_profile.name
  }

  user_data = base64encode(data.template_file.nat_userdata.rendered)
}

data "template_file" "nat_userdata" {
  template = "file(nat-userdata.sh)"

}

resource "aws_eip" "nat-elastic-ips" {
  count = 3

  tags = {
    Name = "nat-${count.index}"
  }
}

resource "aws_security_group" "nat" {
  name        = "nat"
  description = "Allow nat traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.39.154.82/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_instance_profile" "nat_profile" {
  name = "nat_profile"
  role = aws_iam_role.nat_role.name
}

resource "aws_iam_role" "nat_role" {
  name = "nat_role"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "nat_policy" {
  name        = "nat-policy"
  description = "nat policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "ec2:Describe*",
          "ec2:AssociateAddress"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.nat_role.name
  policy_arn = aws_iam_policy.nat_policy.arn
}