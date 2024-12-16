#!/bin/bash

#---------------------------------------------
#
# This script starts the Queue Listener. 
# Before that, it checks whether the database connection and the HumHub setup have been completed. 
#
#---------------------------------------------


sleep 5

while true; do

    output=$(/usr/bin/php /var/www/html/protected/yii queue/info 2>&1)

    if [[ "$output" != *"PDOException"* ]]; then    
        break
    else
    
        echo "Worker: Database not configured and initialized. Waiting..."
        sleep 10
    fi
done

/usr/bin/php /var/www/html/protected/yii queue/listen --verbose=1 --color=0
