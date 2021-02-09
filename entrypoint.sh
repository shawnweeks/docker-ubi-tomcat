#!/bin/bash

set -e

entrypoint.py

unset "${!TOMCAT_@}"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib

${HOME}/bin/catalina.sh run &
TOMCAT_PID="$!"

echo "Tomcat running with PID ${TOMCAT_PID}"
wait ${TOMCAT_PID}