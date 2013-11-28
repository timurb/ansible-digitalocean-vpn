## Ansible playbooks

This is a collection of Ansible playbooks I use to automate certain tasks.
They are intended for personal use only and chances are will not suite your needs.
However bugrepots and pull requests are welcome.

All examples below imply that you have setup inventory for you.

## Base image

Sets up the basic server with `vim`, `git` installed, `nano` uninstalled etc.

Usage:
```bash
ansible-playbook bootstrap.yml
```

## OpenVPN server

Sets up the OpenVPN server configured to use with static key.
You need to have a server in your inventory named `vpn` for this to work.

* First you need to generate the static key and place it as `files/static.key`.
(Pay attention to file name: this file is .gitignored but if you change the name you'll
need to handle the gitignore also). You can generate is like the following:
```bash
openvpn --genkey --secret static.key
```

* Check the list of variables in `vpn.yml` and adjust them to your needs.

* Run `ansible-playbook vpn.yml`

If you meet no errors you'll get the OpenVPN server set up and running in less than a minute.

To configure your Ubuntu box to connect to this server do the following:
* Install NetworkManager OpenVPN plugin: `sudo apt-get install network-manager-openvpn-gnome`
* Add the OpenVPN connection from NetworkManager menu:
 * Enter the IP address of your server
 * Select "Static key authentication"
 * Choose `static.key` you've generated a while ago
 * Enter value from the playbook for `server_addr` into "Remote address" field and value for `client_addr` into "Local address".
* Try to connect to VPN using this connection
* Check that you are really using VPN: `curl ipecho.net/plain`

## Autodeploy of VPN server to [Digital Ocean](http://digitalocean.com/)

You can make ansible to do creation of DigitalOcean droplet for you prior to installing OpenVPN onto it.

To do that you need to do the configurations from the previous chapter ("VPN") and do the following additional configuration steps:
* Add line `localhost` to your ansible inventory. My inventory file is looking as follows:
  ```
vpn ansible_ssh_user=root
localhost
```
* Create file `host_vars/localhost` under you ansible configuration directory (i.e. `/etc/ansiblie/host_vars/localhost`)
and put the following content to it:
```yaml
---
do_client_id: YOUR_CLIENT_ID_HERE
do_api_key: YOUR_API_KEY_HERE
do_ssh_key_id: SSH_KEY_ID
```

You can generate your client ID and API key at https://cloud.digitalocean.com/api_access
As for ssh key id, you can only know that by doing manual API request:
```
curl -k 'https://api.digitalocean.com/ssh_keys/?client_id=YOUR_CLIENT_ID&api_key=YOUR_API_KEY'
```
and check the number in "id" field.
* Make sure you can login to your localhost by SSH as yourself or root

When you have the above in place you run the command:
```
./create_vpn.sh
```
and have the VPN server accessible as `vpn` hostname from your localhost in a several moments.

**Important:** If you use `ansible-playbook` instead and you don't have passwordless sudo for yourself
set up on localhost you must run the command with `-K` key (like `ansible-playbook -K vpn_digital_ocean.yml`)
or ansible will hang infinitely.


## Contributing

Pull requests are welcome

## License and Author

* Author:: Timur Batyrshin
* License:: Apache 2.0
