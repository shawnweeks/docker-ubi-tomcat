### Configure
```shell
export TOMCAT_VERSION=9.0.44
export TOMCAT_NATIVE_VERSION=1.2.26
export APR_VERSION=1.7.0
export KEYCLOAK_VERSION=12.0.4
```

### Download
```shell
wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
wget https://archive.apache.org/dist/tomcat/tomcat-connectors/native/${TOMCAT_NATIVE_VERSION}/source/tomcat-native-${TOMCAT_NATIVE_VERSION}-src.tar.gz
wget https://archive.apache.org/dist/apr/apr-${APR_VERSION}.tar.gz
wget https://github.com/keycloak/keycloak/releases/download/${KEYCLOAK_VERSION}/keycloak-saml-tomcat-adapter-${KEYCLOAK_VERSION}.tar.gz
```

### Build
```shell
docker build \
    --progress plain \
    -t ${REGISTRY}/apache/tomcat:${TOMCAT_VERSION} \
    --build-arg BASE_REGISTRY=${REGISTRY} \
    --build-arg TOMCAT_VERSION=${TOMCAT_VERSION} \
    --build-arg TOMCAT_NATIVE_VERSION=${TOMCAT_NATIVE_VERSION} \
    --build-arg APR_VERSION=${APR_VERSION} \
    --build-arg KEYCLOAK_VERSION=${KEYCLOAK_VERSION} \
    .
```

### Push
```shell
docker push ${REGISTRY}/apache/tomcat
```

### Run
```shell
docker run --init -it --rm \
    --name tomcat  \
    -p 8080:8080 \
    ${REGISTRY}/apache/tomcat:${TOMCAT_VERSION}
```

### Run SSL
```shell
keytool -genkey -noprompt -keyalg RSA \
        -alias selfsigned -keystore keystore.jks -storetype jks \
        -storepass changeit -keypass changeit \
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
    -e TOMCAT_KEYSTORE_PASSWORD=changeit \
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
| TOMCAT_FIPS_MODE | Enable or disable FIPS Mode | on |
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


### Tomcat Native
If you need the Tomcat Native Library for another project you can copy ```libapr-1.*``` and ```libtcnative-1.*``` from ```/opt/tomcat/lib```. You'll also need to update ```LD_LIBRARY_PATH``` to include the directory you are using.