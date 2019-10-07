apk add mysql-client
RESULT=`MYSQL_PWD="$MYSQL_PASSWORD" mysql -h $MYSQL_HOST -u $MYSQL_USER -D $MYSQL_DATABASE -e 'SHOW TABLES' | grep -o node | wc -l`
if [ $RESULT -lt 1 ]; then
        mv /tmp/settings/*.* /var/www/html/thunder/sites/default/
        chmod a+w -R /var/www/html/thunder/sites/default
        cd /var/www/html/thunder/ && vendor/bin/drush -y si standard --db-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}/${MYSQL_DATABASE} --site-name=SiteName --account-name=admin --account-pass=admin
          
else
echo "Database is not empty"

fi
echo "settings.php includes" $(cat /var/www/html/thunder/sites/default/settings.php | grep "'database' => '${MYSQL_DATABASE}',")
chown -R nginx:nginx /var/www/html/thunder/sites/
/var/www/html/thunder/vendor/bin/drush en -y prometheus_exporter
/var/www/html/thunder/vendor/bin/drush en -y oauth2_server
/var/www/html/thunder/vendor/bin/drush role-add-perm 'anonymous' 'access prometheus metrics'
/var/www/html/thunder/vendor/bin/drush cr
