ARG BASE_REGISTRY
ARG BASE_IMAGE=redhat/ubi/ubi8
ARG BASE_TAG=8.3

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as build

ARG TOMCAT_VERSION
ARG TOMCAT_PACKAGE=apache-tomcat-${TOMCAT_VERSION}.tar.gz

ARG TOMCAT_NATIVE_VERSION
ARG TOMCAT_NATIVE_PACKAGE=tomcat-native-${TOMCAT_NATIVE_VERSION}-src.tar.gz

ARG APR_VERSION
ARG APR_PACKAGE=apr-${APR_VERSION}.tar.gz

ARG KEYCLOAK_VERSION
ARG KEYCLOAK_PACKAGE=keycloak-saml-tomcat-adapter-${KEYCLOAK_VERSION}.tar.gz

COPY [ "${TOMCAT_PACKAGE}", "${TOMCAT_NATIVE_PACKAGE}", "${APR_PACKAGE}", "${KEYCLOAK_PACKAGE}", "/tmp/" ]

# Splitting this stuff out so it's a little easier to read.
# This is only the build layer so it won't increase the size 
# of the final image.

# Install Build Dependencies
RUN yum install -y gcc make openssl-devel java-11-openjdk-devel

# Extract Tomcat and Keycloak packages and remove example and documentation webapps.
RUN mkdir -p /tmp/tomcat_pkg && \
    tar -xf /tmp/${TOMCAT_PACKAGE} -C "/tmp/tomcat_pkg" --strip-components=1 && \    
    tar -xf /tmp/${KEYCLOAK_PACKAGE} -C "/tmp/tomcat_pkg/lib" && \
    touch /tmp/tomcat_pkg/conf/server.xml && \
    touch /tmp/tomcat_pkg/conf/context.xml && \
    touch /tmp/tomcat_pkg/conf/web.xml && \
    touch /tmp/tomcat_pkg/conf/keycloak-saml.xml && \
    rm -rf /tmp/tomcat_pkg/webapps/*

# Apply fix for STIG V-222978
# Broken in Tomcat 9.0.41
# RUN mkdir /tmp/v-222978 && \
#     cd /tmp/v-222978 && \
#     jar -xf /tmp/tomcat_pkg/lib/catalina.jar org/apache/catalina/util/ServerInfo.properties && \
#     echo 'server.info=Web Server' > org/apache/catalina/util/ServerInfo.properties && \
#     echo 'server.number=1.0.0' >> org/apache/catalina/util/ServerInfo.properties && \
#     echo 'server.built=Jan 1 2000 00:00:00 UTC' >> org/apache/catalina/util/ServerInfo.properties && \
#     jar -uf /tmp/tomcat_pkg/lib/catalina.jar org/apache/catalina/util/ServerInfo.properties

# Build Apache Portal Runtime
RUN mkdir -p /tmp/apr_package && \
    tar -xf /tmp/${APR_PACKAGE} -C "/tmp/apr_package" --strip-components=1 && \
    cd /tmp/apr_package && \
    ./configure && \
    make && \
    make install && \
    # Copy required APR libaries to Tomcat lib directory
    cp /usr/local/apr/lib/libapr-1.* /tmp/tomcat_pkg/lib

# Build Tomcat Native Library    
RUN mkdir -p /tmp/tomcat_native_package && \
    tar -xf /tmp/${TOMCAT_NATIVE_PACKAGE} -C "/tmp/tomcat_native_package" --strip-components=1 && \
    cd /tmp/tomcat_native_package/native && \
    ./configure --with-apr=/usr/local/apr/bin/apr-1-config --with-java-home=/usr/lib/jvm/java-11 --with-ssl=yes --prefix=/tmp/tomcat_pkg && \
    make && \
    make install

###############################################################################
FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ENV TOMCAT_USER tomcat
ENV TOMCAT_GROUP tomcat
ENV TOMCAT_UID 1001
ENV TOMCAT_GID 1001

ENV TOMCAT_HOME=/var/lib/tomcat
ENV TOMCAT_INSTALL_DIR=/opt/tomcat

RUN yum install -y java-11-openjdk-devel && \
    yum clean all && \
    mkdir -p ${TOMCAT_INSTALL_DIR} && \
    mkdir -p ${TOMCAT_HOME} && \
    groupadd -r -g ${TOMCAT_GID} ${TOMCAT_GROUP} && \
    useradd -r -u ${TOMCAT_UID} -g ${TOMCAT_GROUP} -M -d ${TOMCAT_HOME} -s /sbin/nologin ${TOMCAT_USER} && \
    chown ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_HOME} -R

COPY [ "templates/*.j2", "/opt/jinja-templates/" ]
COPY --from=build --chown=root:${TOMCAT_GROUP} [ "/tmp/tomcat_pkg", "${TOMCAT_INSTALL_DIR}/" ]
COPY --chown=root:${TOMCAT_GROUP} [ "entrypoint.sh", "entrypoint.py", "entrypoint_helpers.py", "${TOMCAT_INSTALL_DIR}/" ]

RUN chmod 750 ${TOMCAT_INSTALL_DIR}/conf && \
    chown ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_INSTALL_DIR}/conf/* && \
    chown ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_INSTALL_DIR}/logs && \
    chown ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_INSTALL_DIR}/work && \
    chown ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_INSTALL_DIR}/temp && \
    chmod 755 ${TOMCAT_INSTALL_DIR}/entrypoint.*

EXPOSE 8080 8443

USER ${TOMCAT_USER}
WORKDIR ${TOMCAT_HOME}
ENV PATH=${PATH}:${TOMCAT_INSTALL_DIR}
CMD ["entrypoint.sh"]