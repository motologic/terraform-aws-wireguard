resource "aws_iam_policy" "allow_ec2_add_eip" {
  name = local.base_resource_name

  description = "Terraform Managed. Allows Wireguard instance to attach EIP."
  policy      = data.aws_iam_policy_document.allow_ec2_add_eip.json
  count       = (var.eip_id == null ? 0 : 1) # only used for EIP mode

  tags = local.common_tags

}

resource "aws_iam_policy" "ssm_agent_policy" {
  name   = "${local.base_resource_name}-instance-ssm-agent-perms-policy"
  policy = data.aws_iam_policy_document.ssm_agent_policy.json

  tags = local.common_tags
}
