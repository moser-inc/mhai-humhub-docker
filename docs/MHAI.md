# MHAI Specific Instructions

Checklist to set up a new instance
1. Make a new container setup in the `docker-compose.yml` file by copypasta of an existing one. Use a unique port number.
2. Set a unique environment variable for the instance database connection.
3. Make a new volume name for where the Humhub instance files will be stored.
4. Be sure to set `HUMHUB_CONFIG__COMPONENTS__REDIS__DATABASE` to a unique value to isolate the Redis cache for the instance.
5. Run these commands in mariadb to initialize up the database:

```sql
CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

# Flush privileges to apply changes
FLUSH PRIVILEGES;
``` 
6. Copy the base Humhub template files into the instance:
```
docker compose cp /home/deploy/humhub_mhai_new_site_template_files.zip <service_name>:/tmp/humhub_mhai_new_site_template_files.zip
docker compose run <service_name> unzip -n /tmp/humhub_mhai_new_site_template_files.zip -d /
```

7. Put the appropriate configurations in the file `/var/lib/humhub/config/dynamic.php`
```
docker compose run <service_name> vim /var/lib/humhub/config/dynamic.php
```
 
8. Load the template database found on the home directory (/home/deploy/humhub_mhai_new_site_template_db.sql)
```
docker compose cp /home/deploy/humhub_mhai_new_site_template_db.sql db:/tmp/humhub_mhai_new_site_template_db.sql
docker compose run db sh -c 'cat /tmp/humhub_mhai_new_site_template_db.sql | mariadb -u humhub -p <database_name>'
```

9. Make sure the NGINX configuration is set up correctly for reverse proxy.

10. The site should be able to run with `docker compose up -d <service_name>`

# Appendix

Change production password:
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';
ALTER USER 'humhub'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
exit;
```
 