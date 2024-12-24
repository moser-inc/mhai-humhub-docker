FROM debian:bookworm

ARG HUMHUB_GIT_BRANCH="develop"

RUN apt-get update && apt-get install -y \
    apache2 \
    php-fpm php php-cli \
	php-imagick php-curl php-bz2 php-gd php-intl php-mbstring php-mysql php-zip php-apcu php-xml php-ldap \
    unzip curl zip joe git npm \
    supervisor
    
#------------------------------------------------------------------------------------------------
# PHP, Apache2, FPM Config
#------------------------------------------------------------------------------------------------

RUN sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/g' /etc/php/8.2/cli/php.ini && \ 
    sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/g' /etc/php/8.2/fpm/php.ini && \
    sed -i 's/post_max_size = 8M/post_max_size = 512M/g' /etc/php/8.2/fpm/php.ini && \
    sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 512M/g' /etc/php/8.2/fpm/php.ini && \
    sed -i 's/max_execution_time = 30/max_execution_time = 90/g' /etc/php/8.2/fpm/php.ini && \
    sed -i 's/memory_limit = 128M/memory_limit = 256M/g' /etc/php/8.2/fpm/php.ini && \
    a2enmod ssl rewrite headers proxy_fcgi setenvif proxy_fcgi && \
    a2enconf php8.2-fpm && \
    echo "Listen 8404" > /etc/apache2/ports.conf

COPY files/apache-config.conf /etc/apache2/sites-available/000-default.conf
COPY files/php-fpm-www.conf /etc/php/8.2/fpm/pool.d/www.conf

EXPOSE 80

#------------------------------------------------------------------------------------------------
# Install Requirements: Composer, NPM, Less, Grunt 
#------------------------------------------------------------------------------------------------

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    npm install -g grunt-cli less less-plugin-clean-css

#------------------------------------------------------------------------------------------------
# HumHub Base GIT Install
#------------------------------------------------------------------------------------------------

RUN mkdir -p /opt/humhub
WORKDIR /opt/humhub

RUN git clone https://github.com/humhub/humhub.git /opt/humhub && \
    git config --global --add safe.directory /opt/humhub && \
    git checkout ${HUMHUB_GIT_BRANCH} && \
    composer install --no-interaction --optimize-autoloader --prefer-dist && \
    npm install && \
    grunt build-assets && \
    rm -rf /var/www/html/* && \
    mkdir -p /var/www/html/protected/runtime && \
    cp /opt/humhub/.htaccess.dist /var/www/html/.htaccess && \
    ln -s /var/lib/humhub/uploads/ /var/www/html/ && \
    ln -s /var/lib/humhub/assets/ /var/www/html/ && \
    ln -s /var/lib/humhub/themes/ /var/www/html/ && \
    ln -s /var/lib/humhub/config/ /var/www/html/protected/ && \
    ln -s /var/lib/humhub/modules/ /var/www/html/protected/ && \
    ln -s /var/lib/humhub/logs/ /var/www/html/protected/runtime/ && \
    ln -s /opt/humhub/protected/humhub /var/www/html/protected/ && \
    ln -s /opt/humhub/protected/vendor /var/www/html/protected/ && \
    ln -s /opt/humhub/static /var/www/html/ && \
    mkdir -p /var/lib/humhub-modules-custom && \
    rm -rf /opt/humhub/.git* && \
    rm -rf /opt/humhub/.idea && \
    rm -rf /opt/humhub/.editorconfig && \
    rm -rf /opt/humhub/.php-cs* && \
    rm -rf /opt/humhub/index-test.php && \
    rm -rf /opt/humhub/node_modules && \
    rm -rf /opt/humhub/LICENSE* && \
    rm -rf /opt/humhub/*.js && \
    rm -rf /opt/humhub/*.lock && \
    rm -rf /opt/humhub/*.json && \
    rm -rf /opt/humhub/*.md && \
    rm -rf /opt/humhub/*.dist && \
    rm -rf /opt/humhub/robots.txt && \
    rm -rf /root/.cache && \
    rm -rf /root/.npm && \
    rm -rf /var/lib/apt/lists/*

# We cannot symlink these entry scripts atm, since the DynamicConfig is otherwise loaded from /opt/humhub
RUN cp /opt/humhub/protected/yii /var/www/html/protected/ && \
    cp /opt/humhub/index.php /var/www/html/index.php

#------------------------------------------------------------------------------------------------
   
COPY ["files/humhub-queue-listen.sh", "files/humhub-cron.sh", "files/humhub-startup.sh", "files/docker-entrypoint.sh", "/"]
RUN chmod +x /humhub-queue-listen.sh && \
    chmod +x /humhub-cron.sh && \
    chmod +x /humhub-startup.sh && \
    chmod +x /docker-entrypoint.sh && \
    mkdir -p /var/log/supervisord && \
    mkdir -p /var/run/supervisord

COPY files/supervisord.conf /etc


#------------------------------------------------------------------------------------------------

ENV HUMHUB_CONFIG__COMPONENTS__URL_MANAGER__SHOW_SCRIPT_NAME=false
ENV HUMHUB_CONFIG__COMPONENTS__URL_MANAGER__ENABLE_PRETTY_URL=true
ENV HUMHUB_CONFIG__MODULES__INSTALLER__ENABLE_AUTO_SETUP=true
ENV HUMHUB_CONFIG__MODULES__MARKETPLACE__MODULE_BLACKLIST='["updater"]'
ENV HUMHUB_CONFIG__PARAMS__MODULE_AUTOLOAD_PATHS='["/var/lib/humhub/modules-custom"]'
ENV HUMHUB_WEB_CONFIG__COMPONENTS__REQUEST__TRUSTED_HOSTS='["0.0.0.0/0"]'
ENV HUMHUB_CONFIG__RUNTIME_PATH=/var/www/html/protected/runtime
ENV HUMHUB_ALIASES__WEBROOT=/var/www/html
ENV HUMHUB_ALIASES__APP=/var/www/html/protected
ENV HUMHUB_ALIASES__CONFIG=/var/www/html/protected/config
ENV HUMHUB_ALIASES__HUMHUB=/var/www/html/protected/humhub

CMD ["/docker-entrypoint.sh"]