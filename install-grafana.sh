#!/bin/bash
wget -q -O gpg.key https://rpm.grafana.com/gpg.key
sudo rpm --import gpg.key

cat >/etc/yum.repos.d/grafana.repo<<EOL
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
repo_gpgcheck=1
enabled=1
gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
EOL

yum install grafana -y

systemctl daemon-reload
systemctl start grafana-server
systemctl enable grafana-server.service
