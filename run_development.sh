#!/bin/bash

export LANG='en_US.UTF-8'

cd "`dirname "$0"`"
source ./.venv/bin/activate
python3 ./avto-lux/manage.py dev-server
