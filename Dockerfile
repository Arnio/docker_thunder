# FROM arnio/ubuntu-fpm7.3:1.0
# FROM arnio/centos7-fpm7.3:1.0
FROM arnio/alpine-fpm7.3

ADD /thunder-8.x-2.44-core.tar.gz /var/www/html/

RUN cd /var/www/html/thunder-8.x-2.44 && \
    composer install --no-progress --profile --prefer-dist && \
    chown -R nginx:nginx /var/www/html

COPY ./default /etc/nginx/conf.d/default.conf
EXPOSE 80
ENTRYPOINT [ "start.sh" ]
