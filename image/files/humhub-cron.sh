#!/bin/bash

sleep 5

while true; do

    output=$(/usr/bin/php /var/www/html/protected/yii queue/info 2>&1)

    if [[ "$output" != *"PDOException"* ]]; then    
        break
    else
    
        echo "Cron: Database not configured and initialized. Waiting..."
        sleep 10
    fi
done

while true; do

    /usr/bin/php /var/www/html/protected/yii cron/run
    sleep 60

done