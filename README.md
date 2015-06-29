avto-lux161
===========

How to deploy
-------------

1. Clone this repo and go to the cloned directory:
  
  ```bash
  $ git clone https://github.com/web-izmerenie/avto-lux161 avto-lux161
  $ cd avto-lux161
  ```
2. Install git-submodules:
  
  ``` bash
  $ git submodule update --init
  ```
  
3. Create Python virtual environment and activate it:
  
  ```bash
  $ pyvenv .venv
  $ source ./.venv/bin/activate
  ```
  
4. Install Python requirements:
  
  ```bash
  $ pip3 install -r requirements.txt
  ```
  
5. Copy [config.yaml.example](./config.yaml.example) to `config.yaml` and
  set in `config.yaml`:
  
  1. `DATABASE` — set correct access data to database;
  2. `DEV_SERVER` — if you going to start development server;
  3. `PRODUCTION_SERVER` — if you going to start production server.<br>
    <b>WARNING!:</b> don't set instances more than <b>1</b>,
    cause it isn't supported yet, need some debug for errors;
  4. `DEBUG` — set to <b>1</b> if you wan't more debug info.
  
6. Copy `./files/uploaded/` dir from backup archive to `./files/uploaded/`.
  
  Just for example:
  
  ```bash
  $ cd files
  $ tar -xzf ../avtolux_files_backup_20150308050634.tar.gz --strip-components=1 files/uploaded/
  ```
  
7. Fill database by database dump from backup archive:
  
  ```bash
  $ cat avtolux_db_dump_20150308041213.sql.gz | gunzip | psql --host localhost -U avtolux_user avtolux_dbname
  ```
  
  Where `avtolux_db_dump_20150308041213.sql.gz` is database dump,
  `avtolux_user` is user for database access
  and `avtolux_dbname` is a database name;
  
8. Install <b>npm</b> dependencies and build some front-end stuff:
  
  ```bash
  $ npm install
  ```
  
  It automatically runs `./deploy.sh` after install
  and installs some <b>bower</b> dependencies
  and build front-end by `./front-end-gulp` tool;
  
9. Run debug server:
  
  ```bash
  $ ./run_development.sh
  ```
  
  Or production:
  ```bash
  $ ./run_production.sh
  ```
