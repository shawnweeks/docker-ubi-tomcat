#!/bin/sh

set -e

startup() {
    echo Starting Tomcat Server
    ${CATALINA_HOME}/bin/startup.sh
    sleep 15
    tail -n +1 -F ${CATALINA_HOME}/logs/*
}

shutdown() {
    echo Stopping Tomcat Server
    ${CATALINA_HOME}/bin/shutdown.sh
}

trap "shutdown" INT
entrypoint.py
startup