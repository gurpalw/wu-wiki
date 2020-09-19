resource "aws_autoscaling_group" "bastion_asg" {
  count               = 3
  name                = "bastion-${count.index}"
  vpc_zone_identifier = [module.vpc.public_subnets[count.index]]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.bastion_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "bastion-${count.index}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "bastion_launch_template" {
  name_prefix            = "bastion"
  image_id               = "ami-08a2aed6e0a6f9c7d"
  instance_type          = "t2.micro"
  key_name               = "gurpal-2020"
  vpc_security_group_ids = [aws_security_group.bastion.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.bastion_profile.name
  }

  user_data = base64encode(data.template_file.bastion_userdata.rendered)
}

data "template_file" "bastion_userdata" {
  template = file("bastion-userdata.sh")
}

resource "aws_eip" "bastion-elastic-ips" {
  count = 1

  tags = {
    Name = "bastion-${count.index}"
  }
}

resource "aws_security_group" "bastion" {
  name        = "bastion"
  description = "Allow bastion traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["82.39.154.82/32"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["82.39.354.82/32"]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "bastion_profile"
  role = aws_iam_role.bastion_role.name
}

resource "aws_iam_role" "bastion_role" {
  name = "bastion_role"
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

resource "aws_iam_policy" "bastion_policy" {
  name        = "bastion-policy"
  description = "bastion policy"

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

resource "aws_iam_role_policy_attachment" "bastion_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = aws_iam_policy.bastion_policy.arn
}
