# FROM arnio/ubuntu-fpm7.3:1.0
# FROM arnio/centos7-fpm7.3:1.0
FROM arnio/alpine-fpm7.3

# ADD /thunder-8.x-2.44-core.tar.gz /var/www/html/
ADD /thunder-8.x-3.1-core.tar.gz /tmp/
RUN mv /tmp/thunder-8.x-3.1 /var/www/html/thunder && \
    cd /var/www/html/thunder && \
    composer install --no-progress --profile --prefer-dist && \
    composer require drush/drush:master && \
    composer require 'drupal/prometheus_exporter:1.x-dev' && \
    chown -R nginx:nginx /var/www/html && \
    ln -s /var/www/html/thunder/vendor/bin/drush /usr/local/bin/ 
    
COPY ./default /etc/nginx/conf.d/default.conf
COPY ./settings /tmp/settings
COPY ./scripts/*.* /usr/local/bin/
RUN  chmod u+x /usr/local/bin/initapp.sh
EXPOSE 80
ENTRYPOINT [ "start.sh" ]
