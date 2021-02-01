ARG BASE_REGISTRY
ARG BASE_IMAGE=redhat/ubi/ubi8
ARG BASE_TAG=8.3

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as build

ARG TOMCAT_VERSION
ARG TOMCAT_PACKAGE=apache-tomcat-${TOMCAT_VERSION}.tar.gz

ARG KEYCLOAK_VERSION
ARG KEYCLOAK_PACKAGE=keycloak-saml-tomcat-adapter-${KEYCLOAK_VERSION}.tar.gz

COPY [ "${TOMCAT_PACKAGE}", "${KEYCLOAK_PACKAGE}", "/tmp/" ]

RUN mkdir -p /tmp/tomcat_pkg && \
    tar -xf /tmp/${TOMCAT_PACKAGE} -C "/tmp/tomcat_pkg" --strip-components=1 && \
    mkdir -p /tmp/keycloak_pkg && \
    tar -xf /tmp/${KEYCLOAK_PACKAGE} -C "/tmp/tomcat_pkg/lib"    

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
COPY --from=build --chown=${TOMCAT_USER}:${TOMCAT_GROUP} [ "/tmp/keycloak_pkg", "${TOMCAT_HOME}/lib" ]
COPY --chown=${TOMCAT_USER}:${TOMCAT_GROUP} [ "entrypoint.sh", "entrypoint.py", "entrypoint_helpers.py", "${TOMCAT_HOME}/" ]

RUN chmod 755 ${TOMCAT_HOME}/entrypoint.*

EXPOSE 8080 8443

USER ${TOMCAT_USER}
WORKDIR ${TOMCAT_HOME}
ENV PATH=${PATH}:${TOMCAT_HOME}
CMD ["entrypoint.sh"]