

COPY ./default /etc/nginx/conf.d/default.conf
EXPOSE 80
ENTRYPOINT [ "start.sh" ]
