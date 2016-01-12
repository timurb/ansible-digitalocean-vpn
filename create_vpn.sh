#!/bin/sh -e

echo "Script started at $(date)"

if [ "$1" = "--nocreate" ]; then
  shift
else
  ansible-playbook -K vpn_digital_ocean.yml $@
fi

echo -n "Waiting for host to get up "
while ! ping -c 1 -W 5 vpn > /dev/null; do
  echo -n "."
  sleep 1 
done
echo

echo -n "Waiting for SSH server on the host to get up "
while ! nc -z vpn 22; do
  echo -n "."
  sleep 1 
done
sleep 3
echo

ansible-playbook vpn.yml $@
ansible-playbook vpn_teardown.yml $@

which notify-send > /dev/null && notify-send -i call-start 'VPN gateway is online'
which osascript > /dev/null && osascript -e 'display notification "VPN gateway is online" with title "Digital Ocean VPN"'
echo "Script stopped at $(date)"
