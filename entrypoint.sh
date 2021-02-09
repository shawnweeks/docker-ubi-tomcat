#!/bin/bash

set -e

umask 0027

entrypoint.py

unset "${!TOMCAT_@}"

# Adds Tomcat Native to Library Path
# Required for STIG V-222968
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/lib
export LD_LIBRARY_PATH

# Required per STIG V-223002
CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.catalina.STRICT_SERVLET_COMPLIANCE=true"
# Required per STIG V-223003
CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.catalina.connector.RECYCLE_FACADES=true"
# Required per STIG V-223004
CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.catalina.connectorALLOW_BACKSLASH=false"
# Required per STIG V-223005
CATALINA_OPTS="${CATALINA_OPTS} -Dorg.apache.catalina.connector.response.ENFORCE_ENCODING_IN_GET_WRITER=true"
export CATALINA_OPTS

${HOME}/bin/catalina.sh run -security &
TOMCAT_PID="$!"

echo "Tomcat running with PID ${TOMCAT_PID}"
wait ${TOMCAT_PID}