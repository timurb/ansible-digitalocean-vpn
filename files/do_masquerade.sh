#!/bin/sh

# This file was created by Ansible.
# Manual changes will be lost.

# Don't add masquerading rule if it is already exists
iptables -n -t nat -L POSTROUTING | grep -q MASQUERADE && exit 0 ||:

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
