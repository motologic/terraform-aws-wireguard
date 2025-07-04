# AWS Wireguard Server

This is a terraform module to deploy a WireGuard VPN server on AWS.

## Notes

This was forked from the [terraform-aws-wireguard](https://github.com/jmhale/terraform-aws-wireguard) repo, which is no
longer kept up to date.

### Prerequisites

Before using this module, you'll need to generate a key pair for your server and client, and store the server's private
key and client's public key in AWS SSM, which cloud-init will source and add to WireGuard's configuration.

- Install the WireGuard tools for your OS: https://www.wireguard.com/install/
- Generate a key pair for each client
    - `wg genkey | tee client1-privatekey | wg pubkey > client1-publickey`
- Generate a key pair for the server
    - `wg genkey | tee server-privatekey | wg pubkey > server-publickey`
- Add the server private key to the AWS SSM parameter: `/wireguard/wg-server-private-key`
    - `aws ssm put-parameter --name /wireguard/wg-server-private-key --type SecureString --value $ServerPrivateKeyValue`
- Add each client's public key, along with the next available IP address as a key:value pair to the
  wg_client_public_keys map. See Usage for details.

### Variables

| Variable Name                   | Type                       | Required                                                  | Description                                                                                                                              |
|---------------------------------|----------------------------|-----------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------|
| `subnet_ids`                    | `list`                     | Yes                                                       | A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list. |
| `ssh_key_id`                    | `string`                   | Yes                                                       | A SSH public key ID to add to the VPN instance.                                                                                          |
| `vpc_id`                        | `string`                   | Yes                                                       | The VPC ID in which Terraform will launch the resources.                                                                                 |
| `env`                           | `string`                   | Optional - defaults to `prod`                             | The name of environment for WireGuard. Used to differentiate multiple deployments.                                                       |
| `eip_id`                        | `string`                   | Optional                                                  | When specified, the ID of the Elastic IP to which the VPN server will attach.                                                            |
| `target_group_arns`             | `string`                   | Optional                                                  | The Load balancer Target Group to which the vpn server ASG will attach.                                                                  |
| `additional_security_group_ids` | `list`                     | Optional                                                  | Used to allow added access to reach the WG servers or allow load balancer health checks.                                                 |
| `asg_min_size`                  | `integer`                  | Optional - default to `1`                                 | Number of VPN servers to permit minimum, only makes sense in loadbalanced scenario.                                                      |
| `asg_desired_capacity`          | `integer`                  | Optional - default to `1`                                 | Number of VPN servers to maintain, only makes sense in loadbalanced scenario.                                                            |
| `asg_max_size`                  | `integer`                  | Optional - default to `1`                                 | Number of VPN servers to permit maximum, only makes sense in loadbalanced scenario.                                                      |
| `instance_type`                 | `string`                   | Optional - defaults to `t2.micro`                         | Instance Size of VPN server.                                                                                                             |
| `wg_server_net`                 | `cidr address and netmask` | Yes                                                       | The server ip allocation and net - wg_client_public_keys entries MUST be in this netmask range.                                          |
| `wg_client_public_keys`         | `list`                     | Yes                                                       | List of maps of client IP/netmasks and public keys. See Usage for details. See Examples for formatting.                                  |
| `wg_server_port`                | `integer`                  | Optional - defaults to `51820`                            | Port to run wireguard service on, wireguard standard is 51820.                                                                           |
| `wg_persistent_keepalive`       | `integer`                  | Optional - defaults to `25`                               | Regularity of Keepalives, useful for NAT stability.                                                                                      |
| `wg_server_private_key_param`   | `string`                   | Optional - defaults to `/wireguard/wg-server-private-key` | The Parameter Store key to use for the VPN server Private Key.                                                                           |
| `ami_id`                        | `string`                   | Optional - defaults to the newest Ubuntu 16.04 AMI        | AMI to use for the VPN server.                                                                                                           |
| `wg_server_interface`           | `string`                   | Optional - defaults to eth0                               | Server interface to route traffic to for installations forwarding traffic to private networks.                                           |

### Outputs

| Output Name          | Description                                                                                        |
|----------------------|----------------------------------------------------------------------------------------------------|
| `vpn_asg_name`       | The name of the wireguard Auto Scaling Group                                                       |
| `vpn_sg_admin_id`    | ID of the internal Security Group to associate with other resources needing to be accessed on VPN. |
| `vpn_sg_external_id` | ID of the external Security Group to associate with the VPN.                                       |

## TODO

- look into moving from ubuntu to aws linux (start-session is complaining because there is no ec2-user)
    - remove `ssh_key_id` var and rely on ssm start-session
