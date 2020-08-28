# Example Build 
```shell
docker build -t registry.cloudbrocktec.com/apache/docker-tomcat:9.0 .
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
|TOMCAT_SAML_SP_SIGN_KEY|Should this key be used to sign requests|true|
|TOMCAT_SAML_SP_ENCR_KEY|Should this key be used to encrypt requests|false|
|TOMCAT_SAML_SP_KEY|SP private key in PEM format||
|TOMCAT_SAML_SP_CERT|SP certificate in PEM format||
|TOMCAT_SAML_IDP_SIGN_REQ|Does the IDP Require Signatures|true|
|TOMCAT_SAML_IDP_ENTITY_ID|This is the issuer ID of the IDP. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_SSO_BIND_URL|This is the URL for the IDP login service that the client will send requests to. This setting is REQUIRED.||
|TOMCAT_SAML_IDP_SLS_BIND_URL|This is the URL for the IDP’s logout service when using the REDIRECT binding. This setting is REQUIRED.||
<br>

# Example Run Command With WAR
```shell
docker run -it --rm --name tomcat-test \
    -v $PWD/auth-test/target/auth-test-0.0.1-SNAPSHOT.war:/opt/tomcat/webapps/auth-test.war \
    -p 8080:8080 \
    -e TOMCAT_SAML_ENABLED=true \
    -e TOMCAT_SAML_SP_ENTITY_ID=tomcat \
    -e TOMCAT_SAML_SP_SIGN_KEY=true \
    -e TOMCAT_SAML_SP_KEY='PEM_KEY_HERE' \
    -e TOMCAT_SAML_SP_CERT='PEM_CERT_HERE' \
    -e TOMCAT_SAML_IDP_ENTITY_ID=idp \
    -e TOMCAT_SAML_IDP_SIGN_REQ=true \
    -e TOMCAT_SAML_IDP_BIND_URL='https://auth.cloudbrocktec.com/realms/master/protocol/saml' \
    -e TOMCAT_SAML_IDP_SSO_BIND_URL='https://auth.cloudbrocktec.com/realms/master/protocol/saml' \
    -e TOMCAT_SAML_IDP_META_URL='https://auth.cloudbrocktec.com/realms/master/protocol/saml/descriptor' \
    registry.cloudbrocktec.com/apache/tomcat:9.0
```
