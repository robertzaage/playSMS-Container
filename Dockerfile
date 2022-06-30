FROM docker.io/php:7.4-apache

ENV DBUSER=playsms
ENV DBPASS=playsms
ENV DBNAME=playsms
ENV DBHOST=127.0.0.1
ENV DBPORT=3306

# Dependencies
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y \
    && apt install -y \
                   git \
                   mariadb-client \
                   zlib1g-dev \
                   libzip-dev \
                   libpng-dev \
                   unzip \
    && apt autoclean -y \
    && docker-php-ext-install -j$(nproc) gd \
                                         zip \
                                         mysqli \
                                         pdo \
                                         pdo_mysql \
    && ln -s /usr/local/bin/php /usr/bin/php

COPY --from=docker.io/composer:2.3.7 /usr/bin/composer /usr/local/bin/composer

ADD run.sh /run.sh

# playSMS
RUN mkdir /app \
    && git clone --branch 1.4.5 --depth=1 https://github.com/playsms/playsms.git /app \
    && composer update -d /app \
    && mv /app/web/config-dist.php /app/web/config.php \
    && sed -i 's/^error_reporting.*/error_reporting(0);/g' /app/web/config.php \
    && cp -R /app/web/* /var/www/html/ \
    && chown -R www-data.www-data /var/www/html \
    && cp -R /app/daemon/linux/bin/playsmsd.php /usr/local/bin/playsmsd \
    && chmod +x /usr/local/bin/playsmsd \
    && echo "PLAYSMS_PATH=\"/var/www/html\""    > /etc/playsmsd.conf \
    && echo "PLAYSMS_LIB=\"/var/lib/playsms\"" >> /etc/playsmsd.conf \
    && echo "PLAYSMS_BIN=\"/usr/local/bin\""   >> /etc/playsmsd.conf \
    && echo "PLAYSMS_LOG=\"/var/log/playsms\"" >> /etc/playsmsd.conf \
    && echo "DAEMON_SLEEP=\"1\""               >> /etc/playsmsd.conf \
    && echo "ERROR_REPORTING=\"E_ALL ^ (E_NOTICE | E_WARNING)\"" >> /etc/playsmsd.conf \
    && mkdir -p /var/log/playsms \
    && chmod +x /run.sh

HEALTHCHECK --interval=5s --timeout=3s CMD curl --fail http://localhost/index.php || exit 1

CMD ["/run.sh"]
