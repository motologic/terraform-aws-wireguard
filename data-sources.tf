data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# We're using ubuntu images - this lets us grab the latest image for our region from Canonical
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-${var.ubuntu_version}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

#data "aws_ami" "amazon_linux_2023" {
#  #  owners = ["137112412989"] # amazon
#  owners = ["amazon"] # 137112412989
#  most_recent = true
#
#  filter {
#    name   = "name"
##    values = ["al2023-ami-ecs-hvm-2023*-x86_64"]
#    values = ["al2023-ami-2023*-x86_64"]
#  }
##
##  filter {
##    name   = "virtualization-type"
##    values = ["hvm"]
##  }
#}

data "aws_ssm_parameter" "wg_server_private_key" {
  name = var.wg_server_private_key_param
}
