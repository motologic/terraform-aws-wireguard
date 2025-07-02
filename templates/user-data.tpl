#!/bin/bash -v

# we go with the eip if it is provided
if [ "${use_eip}" != "disabled" ]; then
  export TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
  export INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $${TOKEN}" -s http://169.254.169.254/latest/meta-data/instance-id)
  export REGION=$(curl -H "X-aws-ec2-metadata-token: $${TOKEN}" -fsq http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/[a-z]$//')
  aws --region $${REGION} ec2 associate-address --allocation-id ${eip_id} --instance-id $${INSTANCE_ID}
fi

# install wireguard
dnf install -y wireguard-tools nftables
modprobe wireguard

# set up
cat > /etc/wireguard/wg0.conf <<- EOF
[Interface]
Address = ${wg_server_net}
PrivateKey = ${wg_server_private_key}
ListenPort = ${wg_server_port}

${peers}
EOF

# cleanup
chown -R root:root /etc/wireguard/
chmod -R og-rwx /etc/wireguard/*

# enable ip forwarding
echo 'net.ipv4.ip_forward=1' | tee /etc/sysctl.d/99-wireguard.conf
sysctl -p /etc/sysctl.d/99-wireguard.conf

# enable NAT
nft add table ip nat
nft add chain ip nat postrouting '{ type nat hook postrouting priority 100; }'
nft add rule ip nat postrouting oifname ${wg_server_interface} masquerade

# enable it
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
