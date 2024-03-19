#!/command/with-contenv bashio
# shellcheck shell=bash
set -e

#################
# INITALISATION #
#################

bashio::log.info "Creating folders"
mkdir -p /config/library

######################
# CONFIGURE POSTGRES #
######################

bashio::log.info "Setting postgres..."
if [[ "$DATABASE_URL" == *"localhost"* ]]; then
    echo "... with local database"
    echo "... set database in /config/postgres"
    mkdir -p /config/postgres
    mkdir -p /var/run/postgresql 
    chown postgres:postgres /var/run/postgresql
    chown -R postgres:postgres /config/postgres
    chmod 0700 /config/postgres
    # Create folder
    if [ ! -e /config/postgres/postgresql.conf ]; then
        echo "... init folder"
        sudo -u postgres /usr/lib/postgresql/16/bin/initdb -D /config/postgres
    fi
    chown -R postgres:postgres /config/postgres
    chmod 0700 /config/postgres
    
    echo "... starting server"
    sudo -u postgres service postgresql start
    sleep 5
    
    echo "... create user and table"
    # Set password
    sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'homeassistant';"
    
    # Create database if does not exist
    echo "CREATE ROLE postgres WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD 'homeassistant';
         CREATE DATABASE linkwarden; CREATE USER postgres WITH ENCRYPTED PASSWORD 'homeassistant'; GRANT ALL PRIVILEGES ON DATABASE linkwarden to postgres;
    \q"> setup_postgres.sql
    sudo -u postgres psql "postgres://postgres:homeassistant@localhost:5432" < setup_postgres.sql || true
fi

########################
# CONFIGURE LINKWARDEN #
########################

bashio::log.info "Starting app..."
yarn prisma migrate deploy
docker-entrypoint.sh yarn start
