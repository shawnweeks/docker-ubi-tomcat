# Example Build
```shell
docker build -t registry.cloudbrocktec.com/apache/tomcat:9.0 .
```

# Build Paramters
|Argument|Description|Default|
|-|-|-|
|BASE_REGISTRY|Registry for UBI Source Image|registry.cloudbrocktec.com|
|BASE_IMAGE|Image for UBI|redhat/ubi/ubi8|
|BASE_TAG|RedHat UBI Tag Version|8.2|
|TOMCAT_MIRROR|Apache Mirror Used to Download Tomcat 9|https://mirrors.gigenet.com/apache|
|TOMCAT_VERSION|Apache Tomcat 9 Version|9.0.37|
|KEYCLOAK_MIRROR|Keycloak Download Mirror|https://downloads.jboss.org/keycloak|
|KEYCLOAK_VERSION|Keycloak Adapter Version|11.0.1|
<br>

# Run Parameters
|Environment Variable|Description|Default|
|---|---|---|
|TOMCAT_PROXY_NAME|External URL for Reverse Proxy||
|TOMCAT_PROXY_PORT|External Port for Reverse Proxy|443|
|TOMCAT_SCHEME|URL Schema|https|
|TOMCAT_SECURE|URL Secure|true|
|TOMCAT_SAML_ENABLED|Enables Keycloak SAML Adapter for Tomcat|false|
|TOMCAT_SAML_SP_ENTITY_ID|The identifier for this client||
|TOMCAT_SAML_SP_SIGN|Should SP Sign Requests. Requires Private Key|false|
|TOMCAT_SAML_SP_KEY|SP private key in PEM format||
|TOMCAT_SAML_SP_CERT|SP certificate in PEM format||
|TOMCAT_SAML_IDP_SIGN|Does the IDP Sign Requests|true|
|TOMCAT_SAML_IDP_ENTITY_ID|This is the issuer ID of the IDP. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_BINDING_URL|This is the URL for the IDP login service that the client will send requests to. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_LOGOUT_BINDING_URL|This is the URL for the IDP’s logout service when using the REDIRECT binding. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_CERT|IDP Certificate in PEM Format||
<br>

# Example Run Command With WAR
```shell
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