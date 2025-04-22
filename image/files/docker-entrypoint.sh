#!/bin/bash

#----------------------------------------------------------------------
# MOUNTED DATA FOLDER HANDLING
#----------------------------------------------------------------------

#--- Ensure mounted data folder structure
mkdir -p /var/lib/humhub/{uploads,assets,logs,config,modules,modules-custom,themes}

#--- Copy defaults (if not exist) to mounted data folder
cp -rn /opt/humhub/protected/config/ /var/lib/humhub/
cp -rn /opt/humhub/uploads/ /var/lib/humhub/
rm -rf /var/lib/humhub/themes/HumHub && cp -rf /opt/humhub/themes/HumHub /var/lib/humhub/themes/HumHub

#--- Check Permissions
chown -R www-data:www-data /var/www/html/protected/runtime
chown -R www-data:www-data /var/lib/humhub/*

cd /var/www/html/

#----------------------------------------------------------------------
# HUMHUB INIT
#----------------------------------------------------------------------
su www-data -s /bin/bash -c '/humhub-startup.sh'

#----------------------------------------------------------------------
# BUILD & compile THEMES
#----------------------------------------------------------------------

echo "Installing MHAI theme..."
if [ ! -f /var/lib/humhub/themes/MHAI/css/theme.css ]; then
  echo "MHAI theme not detected, rebuilding"
  rm -rf /var/lib/humhub/themes/MHAI && cp -rf /opt/humhub/themes/MHAI /var/lib/humhub/themes/MHAI
  lessc --clean-css /var/www/html/themes/MHAI/less/build.less /var/www/html/themes/MHAI/css/theme.css
fi

#----------------------------------------------------------------------
# STARTUP
#----------------------------------------------------------------------

if [ -z "$@" ]; then
  exec /usr/bin/supervisord -c /etc/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin $@
fi