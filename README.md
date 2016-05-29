# avto-lux161

## How to deploy

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
  
  Or if you don't have any backups skip this item and go to the next one.
  
7. Fill database by database dump from backup archive:
  
  If you have started without any backups [read this](#deploy-with-clean-database)
  and skip this item.
  
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
  
9. Run web-server:

  In debug mode:
  ```bash
  $ ./run_development.sh
  ```
  
  Or in production mode:
  ```bash
  $ ./run_production.sh
  ```

## Useful information

### Deploy with clean database

If you start with new empty database, run this command before start server:

```bash
$ ./avto-lux/manage.py dbsync
```

And then create new admin user:
```bash
$ ./avto-lux/manage.py create-admin
```
It will create accout with login `admin` and password `admin`.<br>
<b>WARNING!</b> Do not foget to go to `/adm/` route and change this login/password.

After that you can go to `/adm/#panel/pages` route and create main page
(page with path `/`).

Now it would be good to add some data fields that used on site,
go to route `/adm/#panel/data/add.html` and create this fields
(for `name` field in every level just use any useful human-name
and use number value for `sort`, main key is `symbol key`):
  1. `phones`:
    1.1. `header` text (multiple)
    1.2. `footer` text (single)
  2. `email`:
    2.1. `footer` text (single)
  3. `counters`:
    3.1. `bottom_counters` multiline text (multiple)
  4. `robots`
    4.1. `robots` multiline text (single) with value:
      ```robots
      User-agent: *
      Disallow: /adm/
      Disallow: /static/admin-templates/
      Disallow: /static/ckeditor/
      ```
