#!/usr/bin/env bash
sudo apt update -y 
ip=$(hostname -I|cut -f1 -d ' ')
echo "Your Server IP address is:$ip"

echo -e "\e[32mInstalling essential packages\e[39m"

sudo apt-get install -y \
    	     apt-transport-https \
             ca-certificates \
             curl \
             software-properties-common \
             git \
              gnutls-bin

echo -e "\e[32mInstalling \e[39m"

git clone https://github.com/mHs-98/Ocserv-automation.git  /home/ubuntu/Ocserv-automation

mkdir  /home/ubuntu/certificates
cd  /home/ubuntu/certificates

cat << EOF > ca.tmpl
cn = "VPN CA"
organization = "NCR OCR"
serial = 1
expiration_days = 3650
ca
signing_key
cert_signing_key
crl_signing_key
EOF

certtool --generate-privkey --outfile ca-key.pem
certtool --generate-self-signed --load-privkey ca-key.pem --template ca.tmpl --outfile ca-cert.pem

cat << EOF > server.tmpl
#yourIP
cn=$ip
organization = "my company"
expiration_days = 3650
signing_key
encryption_key
tls_www_server
EOF

certtool --generate-privkey --outfile server-key.pem
certtool --generate-certificate --load-privkey server-key.pem --load-ca-certificate ca-cert.pem --load-ca-privkey ca-key.pem --template server.tmpl --outfile server-cert.pem

echo -e "\e[32mInstalling ocserv\e[39m"
sudo apt install ocserv -y
sudo rm /etc/ocserv/ocserv.conf
cp  /home/ubuntu/certificates/* /etc/ocserv/
cp  /home/ubuntu/Ocserv-automation/scripts/ocserv.conf /etc/ocserv/
iptables -t nat -A POSTROUTING -j MASQUERADE
sed -i -e 's@#net.ipv4.ip_forward=@net.ipv4.ip_forward=1@g' /etc/sysctl.conf
#cp /home/ubuntu/openconnect-vpn-server/ocserv.conf /etc/ocserv/ocserv.conf

echo -e "\e[32mExecute python script to generare username an passwd\e[39m"
cd /home/ubuntu/Ocserv-automation/scripts/
#cp ocserv.conf /etc/ocserv/
python3 randomgen.py

echo -e "\e[32mExecute bash script to users\e[39m"
#cd ~/Ocserv-automation/scripts
cd /home/ubuntu/Ocserv-automation/scripts/
bash stack3.sh
