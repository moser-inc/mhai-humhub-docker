# Migrate

## 1. Get Docker Setup up and running

Please see steps in the README.md for more details.

## 2. Dump the existing database

Dump your existing database for import into docker.

```bash
mkdir -p /opt/humhub
mysqldump -u humhub_prod -p humhub_prod_db > export.sql
```

Replace humhub_prod with your DB username and humhub_prod_db with the name of your MariaDB database.

## 3. Import Database

```
cd /opt/humhub
docker compose up -d

#... wait a bit until database is fully up and running!

./helper.sh import-db export.sql

docker compose down
```

### 4. Copy Installation files

If your existing (non docker) HumHub installation is on another path than `/var/www/humhub` you need to change the folder in the following commands.

**Copy uploaded files to the Docker container**

```
cp -r /var/www/humhub/uploads /opt/humhub/humhub-data/uploads
```

**Copy individual theme to the Docker container (optional)**

```
cp -r /var/www/humhub/themes/YourThemeName /opt/humhub/humhub-data/themes/YourThemeName
```

**Copy individual modules to the Docker container (optional)**

```
cp -r /var/www/humhub/protected/modules/YourSpecialModule /opt/humhub/humhub-data/modules-custom/YourSpecialModule
```

There is no need to copy modules obtained from the Marketplace. The latest suitable module version is installed automatically when the container starts.  


### 5. Migrate configurations

If you have made any special configurations for the config file, you can copy them to the Docker container under /opt/humhub/humhub-data/config.

A pretty URL configuration is not necessary.
