echo "Removing php and apache";
sudo yum remove php;
sudo yum remove httpd;

yes | sudo rm -rf /etc/httpd;

echo "Installing yum utilities";
yes | sudo yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm;
yes | sudo yum install http://rpms.remirepo.net/enterprise/remi-release-7.rpm;
yes | sudo yum install yum-utils -y;

echo "Installing apache";
yes | sudo yum install httpd -y;

echo "Installing SSL";
yes | sudo yum install mod_ssl openssl -y;

echo "Installing PHP versions";
yes | sudo yum install php70 -y;
yes | sudo yum install php71 -y;

echo "Installing PHP FPM";
yes | sudo yum install php70-php-fpm php70-php-xml.x86_64 php70-php-mbstring.x86_64 php70-php-gd.x86_64 php70-php-common.x86_64 php70-php-pecl-zip.x86_64 -y;
yes | sudo yum install php71-php-fpm php71-php-xml.x86_64 php71-php-mbstring.x86_64 php71-php-gd.x86_64 php71-php-common.x86_64 php71-php-pecl-zip.x86_64 -y;

echo "Stopping php service";
sudo systemctl stop php70-php-fpm;
sudo systemctl stop php71-php-fpm;

echo "Set PHP FPM to port";
sudo sed -i 's/:9000/:9070/' /etc/opt/remi/php70/php-fpm.d/www.conf;
sudo sed -i 's/:9000/:9071/' /etc/opt/remi/php71/php-fpm.d/www.conf;

echo "Start PHP FPM";
sudo systemctl start php70-php-fpm
sudo systemctl start php71-php-fpm

sudo cat > /var/www/cgi-bin/php70.fcgi << EOF
#!/bin/bash
exec /bin/php70-cgi
EOF

sudo cat > /var/www/cgi-bin/php71.fcgi << EOF
#!/bin/bash
exec /bin/php71-cgi
EOF

sudo chmod 755 /var/www/cgi-bin/php70.fcgi;
sudo chmod 755 /var/www/cgi-bin/php71.fcgi;

yes | sudo rm /etc/httpd/conf.d/php.conf;

cat > /etc/httpd/conf.d/php.conf << EOF
ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
AddHandler php70-fcgi .php
Action php70-fcgi /cgi-bin/php70.fcgi
Action php71-fcgi /cgi-bin/php71.fcgi
EOF

echo "Appending config files to httpd.conf.";
sudo echo 'Include /var/www/vhosts/*.conf' >> /etc/httpd/conf/httpd.conf

sudo systemctl enable httpd
sudo systemctl enable php70-php-fpm
sudo systemctl enable php71-php-fpm

#
# Optional utilities
#
yes | sudo yum install php71-php-pdo.x86_64 php71-php-pdo_mysql.x86_64 php70-php-mysqlnd.x86_64 php71-php-mysqlnd.x86_64


#
# NOTE:
# After completing everthing manually set User and Group in /etc/httpd/conf/httpd.conf to both "vagrant"
#