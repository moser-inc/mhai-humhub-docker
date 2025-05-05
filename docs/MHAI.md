# MHAI Specific Instructions

Checklist to set up a new instance
1. Make a new container setup in the `docker-compose.yml` file by copypasta of an existing one. 
2. Set a unique environment variable for the instance database connection.
3. Make a new volume name for where the Humhub instance files will be stored. 
4. Run these commands in mariadb to initialize up the database:

```sql
CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

# Flush privileges to apply changes
FLUSH PRIVILEGES;
``` 
5. Copy the base Humhub template files into the instance:
```
docker compose cp /home/deploy/humhub_mhai_new_site_template_files.zip <service_name>:/tmp/humhub_mhai_new_site_template_files.zip
docker compose exec <service_name> unzip -n /tmp/humhub_mhai_new_site_template_files.zip -d /
```

6. Put the appropriate configurations in the file `/var/lib/humhub/config/dynamic.php`
 
7. Load the template database found on the home directory (/home/deploy/humhub_mhai_new_site_template_db.sql)
```
docker compose cp /home/deploy/humhub_mhai_new_site_template_db.sql db:/tmp/humhub_mhai_new_site_template_db.sql
docker compose exec db sh -c 'cat /tmp/humhub_mhai_new_site_template_db.sql | mariadb -u humhub -p <database_name>'
```

# Appendix

Change production password:
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
ALTER USER 'root'@'%' IDENTIFIED BY 'new_password';
ALTER USER 'humhub'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
exit;
```
 