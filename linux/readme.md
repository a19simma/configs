## Install ansible
apt-get install ansible -y

## Run pull command
ansible-pull -U https://github.com/a19simma/configs.git -i ./linux/hosts ./linux/local.yml
