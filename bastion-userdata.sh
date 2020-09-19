#!/bin/bash

sudo yum -y update
export instance_id="$(wget -q -O - http://169.254.169.254/latest/meta-data/instance-id)"
export instance_name="$(aws ec2 describe-tags --filters Name=resource-id,Values=$instance_id Name=key,Values=Name --query Tags[].Value --output text --region eu-west-1)"
export eip_id="$(aws ec2 describe-addresses --filters Name=tag:Name,Values=$instance_name --query Addresses[].AllocationId --output text --region eu-west-1)"
aws ec2 associate-address --instance-id $instance_id --allocation-id $eip_id --region eu-west-1