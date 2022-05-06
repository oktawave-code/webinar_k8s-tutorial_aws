#!/bin/bash
set -e
for s in $( jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" /mnt/secrets/*); do
    export $s
done

export DB_USER=${username}
export DB_PASS=${password}
export DB_HOST=$(echo ${host} | awk -F: '{print $1}')
export DB_PORT=${port}
export DB_NAME=mydb

python manage.py migrate 
python manage.py runserver 0.0.0.0:8000
