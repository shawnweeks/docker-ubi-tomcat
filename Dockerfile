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
    rm -rf /tmp/tomcat_pkg/webapps/*

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

ENV TOMCAT_HOME=/opt/tomcat
ENV PATH=$PATH:$CATALINA_HOME/bin

RUN yum install -y python3 python3-jinja2 java-11-openjdk-devel && \
    yum clean all && \
    mkdir -p ${TOMCAT_HOME} && \
    groupadd -r -g ${TOMCAT_GID} ${TOMCAT_GROUP} && \
    useradd -r -u ${TOMCAT_UID} -g ${TOMCAT_GROUP} -M -d ${TOMCAT_HOME} ${TOMCAT_USER} && \
    chown ${TOMCAT_USER}:${TOMCAT_GROUP} ${TOMCAT_HOME}

COPY [ "templates/*.j2", "/opt/jinja-templates/" ]
COPY --from=build --chown=${TOMCAT_USER}:${TOMCAT_GROUP} [ "/tmp/tomcat_pkg", "${TOMCAT_HOME}/" ]
COPY --chown=${TOMCAT_USER}:${TOMCAT_GROUP} [ "entrypoint.sh", "entrypoint.py", "entrypoint_helpers.py", "${TOMCAT_HOME}/" ]

RUN chmod 755 ${TOMCAT_HOME}/entrypoint.*

EXPOSE 8080 8443

USER ${TOMCAT_USER}
WORKDIR ${TOMCAT_HOME}
ENV PATH=${PATH}:${TOMCAT_HOME}
CMD ["entrypoint.sh"]