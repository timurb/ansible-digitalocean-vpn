#!/bin/sh -e

ansible-playbook -K vpn_digital_ocean.yml $@

echo -n "Waiting for host to get up "
while ! ping -c 1 -W 5 vpn > /dev/null; do
  echo -n "."
  sleep 1 
done
echo

echo -n "Waiting for SSH server on the host to get up "
while ! netcat -z vpn 22; do
  echo -n "."
  sleep 1 
done
echo

ansible-playbook vpn.yml $@
ansible-playbook vpn_teardown.yml $@

which notify-send > /dev/null && notify-send -i call-start 'VPN gateway is online'
