resource "aws_security_group" "wireguard_external" {
  name        = "${local.base_resource_name}-external"
  description = "Terraform Managed. Allow Wireguard client traffic from internet."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    "Name" = local.base_resource_name
  })

  ingress {
    from_port   = var.wg_server_port
    to_port     = var.wg_server_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#resource "aws_security_group" "wireguard_admin" {
#  name        = "${var.base_resource_name}-admin"
#  description = "Terraform Managed. Allow admin traffic to internal resources from VPN"
#  vpc_id      = var.vpc_id
#
#  tags = merge(local.common_tags, {
#    "Name" = local.base_resource_name
#  })
#
#  ingress {
#    from_port       = 0
#    to_port         = 0
#    protocol        = "-1"
#    security_groups = [aws_security_group.wireguard_external.id]
#  }
#
#  ingress {
#    from_port       = 8
#    to_port         = 0
#    protocol        = "icmp"
#    security_groups = [aws_security_group.wireguard_external.id]
#  }
#
#  egress {
#    from_port   = 0
#    to_port     = 0
#    protocol    = "-1"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
#}
