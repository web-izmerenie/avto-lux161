#!/bin/bash

cd "`dirname "$0"`"
chown root:avtolux -R .
chmod o-rwx -R .
chmod g-w -R .
chmod g+w -R ./files/uploaded/
