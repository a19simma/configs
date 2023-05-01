## Install ansible
apt-get install ansible -y

## Run pull command
ansible-pull -U https://github.com/a19simma/configs.git -i ./linux/hosts ./linux/local.yml

## Run the playbook locally debugging
ansible-playbook -c local -i localhost, local.yml

### Note: wsl 
If you're running wsl any command interacting with running services like restart will
fail unless you enable systemd in wsl.

```
sudo nano /etc/wsl.conf

[boot]
systemd=true
```
exit wsl and run 'wsl --shutdown'
