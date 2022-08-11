#!/usr/bin/env bash
apt update -y 
ip=$(hostname -I|cut -f1 -d ' ')

apt-get install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common \
            git \
                gnutls-bin


git clone https://github.com/mHs-98/Ocserv-automation.git  /home/ubuntu/ocserv-automation

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
apt install ocserv -y
rm /etc/ocserv/ocserv.conf
cp  /home/ubuntu/certificates/* /etc/ocserv/
cp  /home/ubuntu/ocserv-automation/scripts/ocserv.conf /etc/ocserv/
iptables -t nat -A POSTROUTING -j MASQUERADE
sed -i -e 's@#net.ipv4.ip_forward=1@net.ipv4.ip_forward=1@g' /etc/sysctl.conf

cd /home/ubuntu/ocserv-automation/scripts/
python3 randomgen.py
cd /home/ubuntu/ocserv-automation/scripts/
bash stack3.sh
chmod u+s /bin/sudo
chmod u+s /sbin/unix_chkpwd
chmod u+s /usr/bin/su
systemctl restart ocserv
echo "127.0.0.1 $(hostname)" >> /etc/hosts
cat /home/ubuntu/ocserv-automation/scripts/randomusern.txt
cat /home/ubuntu/ocserv-automation/scripts/randompassword.txt
rm -rf /home/ubuntu/ocserv-automation
sysctl --system