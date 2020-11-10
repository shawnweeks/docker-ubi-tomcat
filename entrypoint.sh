#!/bin/sh

set -e

startup() {
    echo Starting Tomcat Server
    ${TOMCAT_HOME}/bin/startup.sh
    sleep 15
    tail -n +1 -F ${TOMCAT_HOME}/logs/*
}

shutdown() {
    echo Stopping Tomcat Server
    ${TOMCAT_HOME}/bin/shutdown.sh
}

trap "shutdown" INT
entrypoint.py
startup