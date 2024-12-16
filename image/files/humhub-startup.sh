#!/bin/bash

# Check if the current user is 'www-data'
if [ "$(whoami)" != "www-data" ]; then
  echo "Error: This script must be run as the 'www-data' user." >&2
  exit 1
fi

# Check if HumHub is installed
adminSettings=$(protected/yii settings/list-module admin 2>&1)
if [[ $adminSettings == *"installationId"* ]]; then

   protected/yii cache/flush-all
   protected/yii migrate/up --includeModuleMigrations=1
   protected/yii module/update-all

  # Recompile/Update ThemeBuilder based themes after start
  tbModule=$(protected/yii module/info theme-builder 2>&1)
  if [[ $tbModule == *"Enabled: Yes"* ]]; then
      protected/yii theme-builder/compile-all-less '/usr/bin/lessc'
  fi

fi