# MHAI Specific Instructions

To set up a new instance
* Make a new container setup in the `docker-compose.yml` file by copypasta of an existing one. 
* Set the database environment variable to be unique for the instance. 
* Make a new volume name for where the Humhub instance files will be stored. 
* Run these commands in mariadb to set up the database:

# MySQL useful commands for setup

```sql
CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER '$DB_USER'@'%' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'%';

# Flush privileges to apply changes
FLUSH PRIVILEGES;
``` 

Change production password:
```
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
ALTER USER 'humhub'@'%' IDENTIFIED BY 'new_password';
FLUSH PRIVILEGES;
exit;
```