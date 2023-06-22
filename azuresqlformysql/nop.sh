#!/bin/bash
sudo apt-get update
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get install -y apt-transport-https aspnetcore-runtime-7.0
dotnet --list-runtimes
sudo apt-get install nginx
sudo systemctl start nginx
mkdir /var/www/nopCommerce cd /var/www/nopCommerce
sudo wget https://github.com/nopSolutions/nopCommerce/releases/download/release-4.60.2/nopCommerce_4.60.2_NoSource_linux_x64.zip
sudo apt-get install unzip
sudo unzip nopCommerce_4.60.2_NoSource_linux_x64.zip
sudo mkdir bin
sudo mkdir logs
cd ..
sudo chgrp -R www-data nopCommerce
sudo chown -R www-data nopCommerce
sudo systemctl start nopCommerce.service

