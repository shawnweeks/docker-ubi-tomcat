#!/usr/bin/python3

from entrypoint_helpers import env, gen_cfg

TOMCAT_HOME = env['TOMCAT_HOME']

gen_cfg('server.xml.j2', f'{TOMCAT_HOME}/conf/server.xml')
gen_cfg('context.xml.j2', f'{TOMCAT_HOME}/conf/context.xml')
gen_cfg('web.xml.j2', f'{TOMCAT_HOME}/conf/web.xml')

if 'TOMCAT_SAML_ENABLED' in env and env['TOMCAT_SAML_ENABLED'] == 'true':
    gen_cfg('keycloak-saml.xml.j2', f'{TOMCAT_HOME}/conf/keycloak-saml.xml')
