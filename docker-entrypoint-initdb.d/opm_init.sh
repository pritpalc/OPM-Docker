#!/bin/sh

set -e

# Create the 'template_postgis' template db
su postgres -c "psql --dbname=postgres" <<- 'EOSQL'
CREATE DATABASE opm;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = 'opm';
EOSQL

su postgres -c "psql --dbname=opm" <<-'EOSQL'
		CREATE EXTENSION opm_core;
		SELECT create_admin('admin','admin');
		CREATE EXTENSION hstore;
		CREATE EXTENSION wh_nagios;
		SELECT grant_dispatcher('wh_nagios','postgres');
                CREATE USER opmui WITH ENCRYPTED PASSWORD 'opmui';
                SELECT * FROM grant_appli('opmui');
EOSQL
