#!/bin/bash

date >/timestamp

pki_dir="/etc/icinga2/pki"

export DEBIAN_FRONTEND=noninteractive

wget -O - http://debmon.org/debmon/repo.key 2>/dev/null | apt-key add -
apt-get update
apt-get install -y icinga2 monitoring-plugins monitoring-plugins-basic monitoring-plugins-common monitoring-plugins-standard snmp
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "Icinga2 installed, configuring system.."

echo "$master_ip $master_host" >>/etc/hosts
echo "127.0.2.1 $client_host" >>/etc/hosts

mkdir /run/icinga2 -p


chown nagios.nagios /etc/icinga2 -R
chown nagios.nagios /run/icinga2

rm -rf /etc/icinga2/conf.d/*


icinga2 pki new-cert --cn $client_host --key $pki_dir/$client_host.key --cert $pki_dir/$client_host.crt
icinga2 pki save-cert --key $pki_dir/$client_host.key --cert $pki_dir/$client_host.crt --trustedcert $pki_dir/trusted-cert.crt --host $master_host
icinga2 node setup --ticket $icinga_ticket --zone $client_host --master_host $master_host  --trustedcert  $pki_dir/trusted-cert.crt  --cn $client_host  --endpoint $master_host,$master_ip,5665 --accept-commands --accept-config 

echo "icinga2 pki new-cert --cn $client_host --key $pki_dir/$client_host.key --cert $pki_dir/$client_host.crt" >/icingaconfig.sh
echo "icinga2 pki save-cert --key $pki_dir/$client_host.key --cert $pki_dir/$client_host.crt --trustedcert $pki_dir/trusted-cert.crt --host $master_host" >>/icingaconfig.sh
echo "icinga2 node setup --ticket $icinga_ticket --zone $client_host --master_host $master_host  --trustedcert  $pki_dir/trusted-cert.crt  --cn $client_host  --endpoint $master_host,$master_ip,5665 --accept-commands --accept-config"  >>/icingaconfig.sh

sed -i '$ i object Zone "global-templates" { global = true }' /etc/icinga2/zones.conf

chmod u+s,g+s /bin/ping 
chmod u+s,g+s /bin/ping6 
chmod u+s,g+s /usr/lib/nagios/plugins/check_icmp

date >>/timestamp



icinga2 daemon 

wait
