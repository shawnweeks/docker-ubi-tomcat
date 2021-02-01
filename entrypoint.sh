#!/bin/bash

set -e

entrypoint.py

${HOME}/bin/catalina.sh run &
TOMCAT_PID="$!"

echo "Tomcat running with PID ${TOMCAT_PID}"
wait ${TOMCAT_PID}