FROM debian:jessie
MAINTAINER Mohammad Abdoli Rad <m.abdolirad@gmail.com>

RUN echo "deb http://mirror.leaseweb.net/debian/ stable main" > /etc/apt/sources.list \
    && echo "deb http://mirror.leaseweb.net/debian/ jessie-updates main" >> /etc/apt/sources.list \
    && echo "deb http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list \
    && apt-get update \
    && DEBCONF_FRONTEND=noninteractive apt-get install -y curl wget sudo zsh git \
        zip dnsutils mlocate logrotate locales nano vim \
        nginx openssh-server postgresql-client-9.4 postgresql-9.4 \
        php5-cli php5-curl php-pear php5-dev php5-fpm php5-gd php5-mcrypt \
        php5-intl php5-pgsql php5-xdebug php5-xsl \
    && rm -rf /var/lib/apt/lists/*

COPY assets/configs/ /opt/cake/configs/

COPY assets/install.sh /usr/bin/
RUN chmod 755 /usr/bin/install.sh

COPY assets/init.sh /usr/bin/
RUN chmod 755 /usr/bin/init.sh

RUN /usr/bin/install.sh

WORKDIR /srv/www
ENTRYPOINT ["/usr/bin/init.sh"]
CMD ["start"]

EXPOSE 80 8080 443 5432