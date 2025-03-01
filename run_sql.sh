#!/bin/bash

DB_NAME="JUDGE_DB"
DB_HOST="localhost"

mysql -u root -p -h "$DB_HOST" -e "CREATE SCHEMA IF NOT EXISTS $DB_NAME DEFAULT CHARACTER SET utf8;"

mysql -u root -p -h "$DB_HOST" -D "$DB_NAME" < schema_definition.sql
mysql -u root -p -h "$DB_HOST" -D "$DB_NAME" < views.sql
mysql -u root -p -h "$DB_HOST" -D "$DB_NAME" < functions.sql

for file in stored_procedures/*.sql; do
    mysql -u root -p -h "$DB_HOST" -D "$DB_NAME" < "$file"
done

mysql -u root -p -h "$DB_HOST" -D "$DB_NAME" < insertion_scripts.sql

echo "All scripts executed successfully!" password
