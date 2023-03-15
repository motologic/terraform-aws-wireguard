resource "aws_iam_role" "wireguard_role" {
  name = local.base_resource_name

  description        = "Terraform Managed. Role to allow Wireguard instance to attach EIP."
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  count              = (var.eip_id == null ? 0 : 1) # only used for EIP mode

  tags = local.common_tags
}

resource "aws_iam_instance_profile" "wireguard_profile" {
  name = local.base_resource_name

  role  = aws_iam_role.wireguard_role[0].name
  count = (var.eip_id == null ? 0 : 1) # only used for EIP mode

  tags = local.common_tags
}
