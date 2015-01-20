#!/bin/bash

cd "`dirname "$0"`"
source ./.venv/bin/activate
python3 ./avto-lux/manage.py run 2>/var/log/py/avtolux/production.stderr 1>/dev/null
