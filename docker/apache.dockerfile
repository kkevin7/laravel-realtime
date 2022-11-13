FROM debian:bullseye

RUN apt update
RUN apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 git curl unzip nano wget

#--------------------------- Apache -----------------------------
RUN apt-get install -y apache2
RUN chgrp -R www-data /var/www/html
RUN chown -R www-data:www-data /var/www
RUN chmod -R 777 /var/www/html/
RUN a2dissite 000-default.conf

#Enable Modules
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_balancer
RUN a2enmod lbmethod_byrequests
RUN a2enmod headers

# PHP conf
COPY ./apache/php/php.ini /usr/local/etc/php/php.ini

# Apache Conf
COPY ./apache/vhosts/chat-websockets.test.conf /etc/apache2/sites-available/chat-websockets.test.conf

# Enable Sites
RUN a2ensite chat-websockets.test.conf

#Restart Services
RUN service apache2 restart

#--------------------------- PHP --------------------------------
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list
RUN wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add -
RUN apt update
RUN apt-get install -y php8.1 php8.1-cli php8.1-phpdbg php8.1-fpm php8.1-cgi libphp8.1-embed \
libapache2-mod-php8.1 php8.1-common php8.1-gd php8.1-mysql php8.1-pgsql php8.1-curl php8.1-intl \
php8.1-mbstring php8.1-bcmath php8.1-imap php8.1-xml php8.1-zip php8.1-bz2 php8.1-bcmath \
php8.1-ldap php8.1-pspell php8.1-readline php8.1-dba php8.1-dev php8.1-sqlite

#--------------------------- PHP Composer --------------------------------
RUN wget -qO - https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer

# Composer User
ENV COMPOSER_ALLOW_SUPERUSER 1

#------------ NodeJS --------------------
RUN cd /tmp
RUN curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
RUN bash nodesource_setup.sh
RUN apt-get update
RUN apt-get install -y nodejs

#----------- Yarn -----------------------
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update
RUN apt-get install -y yarn

#------------ Certbot ---------------------
RUN apt install -y certbot python3-certbot-apache

#---------- Supervisor --------------------
RUN apt-get install -y supervisor

# Supervisor Conf
COPY ./apache/supervisor/chat-websockets.conf /etc/supervisor/conf.d/chat-websockets.conf

# Work directory
WORKDIR /var/www/html/


RUN echo 'ServerName 127.0.0.1' >> /etc/apache2/apache2.conf

# Apache ENV
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2/apache2.pid
ENV APACHE_SERVER_NAME localhost

# Entrypoint
COPY ./apache/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Expose Apache
EXPOSE 80

# Launch Apache
CMD ["apachectl", "-D", "FOREGROUND"]
