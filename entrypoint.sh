#!/bin/bash

set -e

shutdown() {
    echo Stopping Tomcat Server
    kill -SIGTERM ${TOMCAT_PID}
}

entrypoint.py

trap "shutdown" TERM INT
${HOME}/bin/catalina.sh run &
TOMCAT_PID="$!"

echo "Tomcat running with PID ${TOMCAT_PID}"
wait ${TOMCAT_PID}