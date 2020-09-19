resource "aws_autoscaling_group" "wiki-js_asg" {
  count               = 1
  name                = "wiki-js-${count.index}"
  vpc_zone_identifier = [module.vpc.private_subnets[count.index]]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.wiki-js_launch_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "wiki-${count.index}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "wiki-js_launch_template" {
  name_prefix            = "wiki-js"
  image_id               = "ami-08a2aed6e0a6f9c7d"
  instance_type          = "t3.small"
  key_name               = "gurpal-2020"
  vpc_security_group_ids = [aws_security_group.wiki-js.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.wiki-js_profile.name
  }

//  user_data = base64encode(data.template_file.wiki-js_userdata.rendered)
}
//
//data "template_file" "wiki-js_userdata" {
//  template = file("wiki-js-userdata.sh")
//}

//resource "aws_eip" "wiki-js-elastic-ips" {
//  count = 1
//
//  tags = {
//    Name = "wiki-js-${count.index}"
//  }
//}

resource "aws_security_group" "wiki-js" {
  name        = "wiki-js"
  description = "Allow wiki-js traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = ["sg-00f97c8766353b546"]
  }

  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_instance_profile" "wiki-js_profile" {
  name = "wiki-js_profile"
  role = aws_iam_role.wiki-js_role.name
}

resource "aws_iam_role" "wiki-js_role" {
  name = "wiki-js_role"
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

resource "aws_iam_policy" "wiki-js_policy" {
  name        = "wiki-js-policy"
  description = "wiki-js policy"

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

resource "aws_iam_role_policy_attachment" "wiki-js_policy_attachment" {
  role       = aws_iam_role.wiki-js_role.name
  policy_arn = aws_iam_policy.wiki-js_policy.arn
}