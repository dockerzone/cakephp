#!/usr/bin/env bash
set -e

CAKE_USER=cake
CAKE_GROUP=cake

# Add & config cake user
echo "$CAKE_USER ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
useradd --create-home --user-group -s /usr/bin/zsh ${CAKE_USER}
sudo -u ${CAKE_USER} -H sh -c "export SHELL=/usr/bin/zsh; curl -L http://install.ohmyz.sh | bash"
sudo -u ${CAKE_USER} -H sh -c "sed -i 's/ZSH_THEME=\".*\"/ZSH_THEME=\"maran\"/g' /home/$CAKE_USER/.zshrc"

# Install Adminer
mkdir -p /srv/tools/adminer
cd /srv/tools/adminer
curl -SLO http://www.adminer.org/latest.php
curl -SLO https://raw.githubusercontent.com/pappu687/adminer-theme/master/adminer.css
curl -SLO https://raw.githubusercontent.com/pappu687/adminer-theme/master/adminer-bg.png
mv latest.php index.php

# Install phpPgAdmin
mkdir -p /srv/tools/phppgadmin
cd /srv/tools/phppgadmin
git clone git://github.com/phppgadmin/phppgadmin.git .
mv conf/config.inc.php-dist conf/config.inc.php
sed -i "s/$conf\['extra_login_security'\] = true/$conf\['extra_login_security'\] = false/g" conf/config.inc.php
sed -i "s/\$conf\['servers'\]\[0\]\['desc'\] = 'PostgreSQL';/\$conf\['servers'\]\[0\]\['desc'\] = 'CakePHP Database';/g" conf/config.inc.php

# PHP Config
cp /etc/php5/fpm/pool.d/www.conf /etc/php5/fpm/pool.d/cake.conf
sed -i "s/\[www\]/\[cake\]/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/user = www-data/user = $CAKE_USER/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/group = www-data/group = $CAKE_USER/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/listen = \/var\/run\/php5-fpm.sock/listen = \/var\/run\/php5-fpm-cake.sock/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/listen.owner = www-data/listen.owner = $CAKE_USER/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/listen.group = www-data/listen.group = $CAKE_GROUP/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/;listen.mode = 0660/listen.mode = 0666/g" /etc/php5/fpm/pool.d/cake.conf
sed -i "s/;date.timezone =/date.timezone = UTC/g" /etc/php5/fpm/php.ini
sed -i "s/;date.timezone =/date.timezone = UTC/g" /etc/php5/cli/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 12M/g" /etc/php5/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/g" /etc/php5/fpm/php.ini
sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/fpm/php.ini
sed -i "s/display_errors = Off/display_errors = On/g" /etc/php5/cli/php.ini
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php5/fpm/php.ini
sed -i "s/display_startup_errors = Off/display_startup_errors = On/g" /etc/php5/cli/php.ini

# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

# Config Nginx
cp /opt/cake/configs/nginx/default /etc/nginx/sites-available/
cp /opt/cake/configs/nginx/cake /etc/nginx/sites-enabled/