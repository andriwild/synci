#!/bin/bash

DB_HOST="localhost"
DB_PORT="5432"
DB_USER="postgres"
DB_PASSWORD="postgres"
DB_NAME="synci-db"

echo "Wait on db-connection..."
until PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c '\q'; do
  >&2 echo "Postgres ist noch nicht bereit - warte 5 Sekunden..."
  sleep 5
done
echo "Postgres is ready!"

echo "Create tables..."
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f ./database/synci-schema.sql

echo "Done!"
