#!/bin/bash

cd "`dirname "$0"`"
chown avtoluxprod:avtolux -R .
chmod o-rwx -R .
chmod g-w -R .
chmod g+w -R ./files/uploaded/
