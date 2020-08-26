# Parameters
|Environment Variable|Description|Default|
|---|---|---|
|TOMCAT_PROXY_NAME|External URL for Reverse Proxy||
|TOMCAT_PROXY_PORT|External Port for Reverse Proxy|80|
|TOMCAT_SCHEME|URL Schema|http|
|TOMCAT_SECURE|URL Secure|false|
|TOMCAT_SAML_ENABLED|Enables Keycloak SAML Adapter for Tomcat|false|
|TOMCAT_SAML_SP_ENTITY_ID|The identifier for this client||
|TOMCAT_SAML_SP_SIGN|Should SP Sign Requests. Requires Private Key|false|
|TOMCAT_SAML_SP_KEY|SP private key in PEM format||
|TOMCAT_SAML_SP_CERT|SP certificate in PEM format||
|TOMCAT_SAML_IDP_SIGN|Does the IDP Sign Requests|true|
|TOMCAT_SAML_IDP_ENTITY_ID|This is the issuer ID of the IDP. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_BINDING_URL|This is the URL for the IDP login service that the client will send requests to. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_LOGOUT_BINDING_URL|This is the URL for the IDP’s logout service when using the REDIRECT binding. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_CERT|IDP Certificate in PEM Format|true|

# Example Run Command
```
docker run -it --rm --name tomcat-test \
    -v $PWD/auth-test/target/auth-test-0.0.1-SNAPSHOT.war:/opt/tomcat/webapps/auth-test.war \
    -p 8080:8080 \
    -e TOMCAT_SAML_ENABLED=true \
    -e TOMCAT_SAML_SP_ENTITY_ID=tomcat \
    -e TOMCAT_SAML_SP_SIGN=false \
    -e TOMCAT_SAML_IDP_SIGN=false \
    -e TOMCAT_SAML_IDP_ENTITY_ID=idp \
    -e TOMCAT_SAML_IDP_BINDING_URL='https://auth.cloudbrocktec.com/realms/master/protocol/saml' \
    -e TOMCAT_SAML_IDP_LOGOUT_BINDING_URL='https://auth.cloudbrocktec.com/realms/master/protocol/saml' \
    registry.cloudbrocktec.com/apache/tomcat:9.0
```