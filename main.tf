# turn the sg into a sorted list of string
locals {
  # make it easier to create resources with identifiable names
  base_resource_name = replace("${var.project_team}-${var.env}-wireguard", "_", "-")

  # clean up and concat the above wireguard default sg with the additional_security_group_ids
  sg_wireguard_external = sort([aws_security_group.wireguard_external.id])
  security_groups_ids   = compact(concat(var.additional_security_group_ids, local.sg_wireguard_external))

  common_tags = {
    Project_Team  = var.project_team
    Resource_Name = "wireguard"
    Environment   = var.env
  }
}

resource "aws_autoscaling_group" "wireguard" {
  name = local.base_resource_name

  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_capacity
  max_size             = var.asg_max_size
  vpc_zone_identifier  = var.subnet_ids
  health_check_type    = "EC2"
  termination_policies = ["OldestLaunchConfiguration", "OldestInstance"]
  target_group_arns    = var.target_group_arns

  launch_template {
    id      = aws_launch_template.wireguard.id
    version = aws_launch_template.wireguard.latest_version
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = local.base_resource_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.env
    propagate_at_launch = true
  }

  tag {
    key                 = "Resource_Name"
    value               = "wireguard"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project_Team"
    value               = var.project_team
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "wireguard" {
  name_prefix = local.base_resource_name
  image_id    = var.ami_id == null ? data.aws_ami.ubuntu.id : var.ami_id

  vpc_security_group_ids = local.security_groups_ids
  key_name               = var.ssh_key_id
  instance_type          = var.instance_type

  user_data = base64encode(templatefile(
    "${path.module}/templates/user-data.tpl",
    {
      wg_server_private_key = data.aws_ssm_parameter.wg_server_private_key.value
      wg_server_net         = var.wg_server_net
      wg_server_port        = var.wg_server_port
      use_eip               = var.eip_id == null ? "disabled" : "enabled"
      eip_id                = var.eip_id
      wg_server_interface   = var.wg_server_interface

      peers = templatefile(
        "${path.module}/templates/client-data.tpl",
        {
          client_pub_keys      = var.wg_client_public_keys
          persistent_keepalive = var.wg_persistent_keepalive
        }
      )
    }
  ))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
    }
  }

  iam_instance_profile {
    name = (var.eip_id == null ? null : aws_iam_instance_profile.wireguard_profile[0].name)
  }

  tag_specifications {
    resource_type = "instance"

    tags = local.common_tags
  }

  tags = local.common_tags
}
