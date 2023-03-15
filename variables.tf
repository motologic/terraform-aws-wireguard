variable "ssh_key_id" {
  description = "A SSH public key ID to add to the VPN instance."
  type        = string
}

variable "instance_type" {
  type        = string
  description = "The machine type to launch, some machines may offer higher throughput for higher use cases."
  default     = "t2.micro"
}

variable "asg_min_size" {
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
  type        = number
  default     = 1
}

variable "asg_desired_capacity" {
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
  type        = number
  default     = 1
}

variable "asg_max_size" {
  description = "We may want more than one machine in a scaling group, but 1 is recommended."
  type        = number
  default     = 1
}

variable "vpc_id" {
  description = "The VPC ID in which Terraform will launch the resources."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnets for the Autoscaling Group to use for launching instances. May be a single subnet, but it must be an element in a list."
  type        = list(string)
}

variable "wg_client_public_keys" {
  description = "List of maps of client IPs and public keys. See Usage in README for details."
  # type        = map(string)
}

variable "wg_server_net" {
  description = "IP range for vpn server - make sure your Client ips are in this range but not the specific ip i.e. not .1"
  type        = string
  default     = "192.168.2.1/24"
}

variable "wg_server_port" {
  description = "Port for the vpn server."
  type        = number
  default     = 51820
}

variable "wg_persistent_keepalive" {
  description = "Persistent Keepalive - useful for helping connection stability over NATs."
  type        = number
  default     = 25
}

variable "eip_id" {
  description = "ID of the Elastic IP to use, when use_eip is enabled."
  type        = string
  default     = null
}

variable "additional_security_group_ids" {
  description = "Additional security groups if provided, default empty."
  type        = list(string)
  default     = [""]
}

variable "target_group_arns" {
  description = "Running a scaling group behind an LB requires this variable, default null means it won't be included if not set."
  type        = list(string)
  default     = null
}

variable "env" {
  description = "The name of environment for WireGuard. Used to differentiate multiple deployments."
  type        = string
  default     = "prd"
}

variable "wg_server_private_key_param" {
  description = "The SSM parameter containing the WG server private key."
  type        = string
  default     = "/wireguard/wg-server-private-key"
}

variable "ami_id" {
  description = "The AWS AMI to use for the WG server, defaults to the latest Ubuntu 22.04 AMI if not specified."
  #  type        = string
  default = null # we check for this and use a data provider since we can't use it here
}

variable "wg_server_interface" {
  description = "The default interface to forward network traffic to."
  type        = string
  default     = "eth0"
}

variable "project_team" {
  description = "Prefix for resource names - shop, rev, or logic"
  type        = string
}

variable "ubuntu_version" {
  description = "The Ubuntu version to use for the server"
  type        = number

  # NOTE: Ubuntu 22.04 is an LTS version, EOL 2027
  default = 22.04
}
