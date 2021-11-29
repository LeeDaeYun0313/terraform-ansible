#!/bin/bash
sudo su -
sudo apt -y update && sudo apt install -y python
useradd bespin -s /bin/bash -m
echo 'bespin:It1' | chpasswd
echo 'bespin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo sed -i "s/#Port 22/Port 60022/g" /etc/ssh/sshd_config
systemctl restart sshd
