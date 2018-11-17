#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

read -p "Please type the user name:" username
echo "Now create user $username"

useradd $username
ssh_dir=/home/${username}/.ssh
mkdir $ssh_dir
wget "https://raw.githubusercontent.com/kenneth-lin/ServerShell/master/rsa_key/key1" -O  authorized_keys_temp
cat authorized_keys_temp > ${ssh_dir}/authorized_keys
rm -f authorized_keys_temp

chmod 755 $ssh_dir
chmod 644 ${ssh_dir}/authorized_keys

# add to wheel is for nopasswd, but you should check it in /etc/sudoers.
usermod -G wheel $username
echo "$username is created."

#userdel $username
#rm -rf /home/${username}