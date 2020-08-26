#!/usr/bin/python3

from entrypoint_helpers import env, gen_cfg
print("Python is running!")

CATALINA_HOME = env['CATALINA_HOME']

print(f'Generating {CATALINA_HOME}/conf/server.xml')
gen_cfg('server.xml.j2', f'{CATALINA_HOME}/conf/server.xml')

print(f'Generating {CATALINA_HOME}/conf/context.xml')
gen_cfg('context.xml.j2', f'{CATALINA_HOME}/conf/context.xml')

if 'TOMCAT_SAML_ENABLED' in env and env['TOMCAT_SAML_ENABLED'] == 'true':
    print(f'Generating {CATALINA_HOME}/conf/keycloak-saml.xml')
    gen_cfg('keycloak-saml.xml.j2', f'{CATALINA_HOME}/conf/keycloak-saml.xml')
