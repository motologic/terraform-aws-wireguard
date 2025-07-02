data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "amazon_linux_2023" {
  owners      = ["amazon"] # 137112412989
  most_recent = true

  filter {
    name = "name"
    # note that the non-ECS AWS Linux 2023 is at 2023.7.x; the ECS is still at 2023.0.x
    # aws --profile logic_dev ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64
    values = ["al2023-ami-2023*-kernel-*-x86_64"]
  }
}

data "aws_ssm_parameter" "wg_server_private_key" {
  name = var.wg_server_private_key_param
}
