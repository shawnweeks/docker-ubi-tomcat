### Download Depencies
```shell
export TOMCAT_VERSION=9.0.41
export KEYCLOAK_VERSION=12.0.2

wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
wget https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-saml-tomcat-adapter-${KEYCLOAK_VERSION}.tar.gz
```

### Build Image
```shell
export TOMCAT_VERSION=9.0.41
export KEYCLOAK_VERSION=12.0.2

docker build \
    -t ${REGISTRY}/apache/tomcat:${TOMCAT_VERSION} \
    --build-arg BASE_REGISTRY=${REGISTRY} \
    --build-arg TOMCAT_VERSION=${TOMCAT_VERSION} \
    --build-arg KEYCLOAK_VERSION=${KEYCLOAK_VERSION} \
    .
```

### Push to Registry
```shell
docker push ${REGISTRY}/apache/tomcat
```

### Simple Run Command
```shell
export TOMCAT_VERSION=9.0.41
docker run --init -it --rm \
    --name tomcat  \
    -p 8080:8080 \
    ${REGISTRY}/apache/tomcat:${TOMCAT_VERSION}
```

### Simple SSL Run Command
```shell
export TOMCAT_VERSION=9.0.41
keytool -genkey -noprompt -keyalg RSA \
        -alias selfsigned -keystore keystore.jks -storepass changeit \
        -dname "CN=localhost" \
        -validity 360 -keysize 2048
docker run --init -it --rm \
    --name tomcat  \
    -v $PWD/keystore.jks:/tmp/keystore.jks \
    -e TOMCAT_PORT=8443 \
    -e TOMCAT_SCHEME=https \
    -e TOMCAT_SECURE=true \
    -e TOMCAT_SSL_ENABLED=true \
    -e TOMCAT_KEY_ALIAS=selfsigned \
    -e TOMCAT_KEYSTORE_FILE=/tmp/keystore.jks \
    -e TOMCAT_KEYSTORE_PASS=changeit \
    -p 8443:8443 \
    ${REGISTRY}/apache/tomcat:${TOMCAT_VERSION}
```

### Build Paramters
| Argument | Description | Default |
| --- | --- | --- |
| BASE_REGISTRY | Registry for UBI Source Image  | registry.cloudbrocktec.com|
| BASE_IMAGE | Image for UBI | redhat/ubi/ubi8|
| BASE_TAG | RedHat UBI Tag Version | 8.2 |
| TOMCAT_MIRROR | Apache Mirror Used to Download Tomcat 9 | https://mirrors.gigenet.com/apache |
| TOMCAT_VERSION | Apache Tomcat 9 Version | 9.0.37 |
| TOMCAT_MIRROR | Keycloak Download Mirror | https://downloads.jboss.org/keycloak |
| TOMCAT_VERSION | Keycloak Adapter Version | 11.0.1 |
<br/>

### Run Parameters
| Environment Variable | Description | Default|
| --- | --- | ---|
| TOMCAT_PROXY_NAME | External URL for Reverse Proxy | None |
| TOMCAT_PROXY_PORT | External Port for Reverse Proxy | None |
| TOMCAT_SCHEME | URL Schema | http |
| TOMCAT_SECURE | URL Secure | false |
| TOMCAT_SSL_ENABLED | Enable Tomcat SSL Support | None |
| TOMCAT_SSL_ENABLED_PROTOCOLS | Allowed SSL Protocols | TLSv1.2,TLSv1.3 |
| TOMCAT_KEY_ALIAS | Tomcat SSL Key Alias | None |
| TOMCAT_KEYSTORE_FILE | Tomcat SSL Keystore File | None |
| TOMCAT_KEYSTORE_PASS | Tomcat SSL Keystore Password | None |
| TOMCAT_KEYSTORE_TYPE | Tomcat SSL Keystore Type | JKS |
| TOMCAT_SAML_ENABLED | Enables Keycloak SAML Adapter for Tomcat | false|
| TOMCAT_SAML_SP_ENTITY_ID | The identifier for this client | |
| TOMCAT_SAML_SP_LOGOUT_PAGE | See Keycloak Documentation | None |
| TOMCAT_SAML_SP_SSL_POLICY | See Keycloak Documentation | None |
| TOMCAT_SAML_SP_NAME_ID_POLICY_FORMAT | See Keycloak Documentation | None |
| TOMCAT_SAML_SP_FORCE_AUTH | See Keycloak Documentation | None |
| TOMCAT_SAML_SP_IS_PASSIVE | See Keycloak Documentation | None |
| TOMCAT_SAML_SP_SIGN_KEY | Use key to sign requests  | true|
| TOMCAT_SAML_SP_ENCR_KEY | Use key to encrypt requests  | false|
| TOMCAT_SAML_SP_KEY | SP private key in PEM format | |
| TOMCAT_SAML_SP_CERT | SP certificate in PEM format | |
| TOMCAT_SAML_SP_NAME_MAP_POLICY | Name mapping policy to be used, can be used to map name from email or other attributes | FROM_NAME_ID |
| TOMCAT_SAML_SP_NAME_MAP_ATTR | If Name mapping policy is set then use this attribute for mapping | None |
| TOMCAT_SAML_IDP_ENTITY_ID | This is the issuer ID of the IDP. For Keycloak this is 'idp' but that may vary. This setting is REQUIRED. | |
| TOMCAT_SAML_IDP_SIGN_REQ | Does the IDP Require Signatures | true|
| TOMCAT_SAML_IDP_REQ_BIND | Request binding method | POST |
| TOMCAT_SAML_IDP_REP_BIND| Response binding method | POST |
| TOMCAT_SAML_IDP_SSO_BIND_URL | This is the URL for the IDP login service that the client will send requests to. This setting is REQUIRED. | None |
| TOMCAT_SAML_IDP_SLS_BIND_URL | This is the URL for the IDP’s logout service when using the REDIRECT binding. This setting is REQUIRED. | None |
<br/>

###  Example Run Command With WAR
```shell
docker run --init -it --rm \
    --name tomcat \
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
