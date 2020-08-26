ARG BASE_REGISTRY=registry.cloudbrocktec.com
ARG BASE_IMAGE=redhat/ubi/ubi8
ARG BASE_TAG=8.2


FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as stage

ARG TOMCAT_MIRROR=https://mirrors.gigenet.com/apache/tomcat/tomcat-9
ARG TOMCAT_VERSION=9.0.37
ENV TOMCAT_DOWNLOAD_URL=${TOMCAT_MIRROR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

ARG KEYCLOAK_MIRROR=https://downloads.jboss.org/keycloak
ARG KEYCLOAK_VERSION=11.0.1
ENV KEYCLOAK_DOWNLOAD_URL=${KEYCLOAK_MIRROR}/${KEYCLOAK_VERSION}/adapters/saml/keycloak-saml-tomcat-adapter-dist-${KEYCLOAK_VERSION}.tar.gz

COPY [ "entrypoint.sh", "entrypoint.py", "entrypoint_helpers.py", "/tmp/tomcat/" ]

RUN dnf install -y wget && \
    wget ${TOMCAT_DOWNLOAD_URL} -P /tmp && \
    wget ${KEYCLOAK_DOWNLOAD_URL} -P /tmp && \
    mkdir -p /tmp/tomcat && \
    tar -xvf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz --strip-components=1 -C /tmp/tomcat && \
    mkdir -p /tmp/keycloak && \
    tar -xvf /tmp/keycloak-saml-tomcat-adapter-dist-${KEYCLOAK_VERSION}.tar.gz -C /tmp/keycloak && \
    cp -n /tmp/keycloak/* /tmp/tomcat/lib && \
    rm -rf /tmp/tomcat/webapps/* && \
    chmod 755 /tmp/tomcat/entrypoint.sh

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG}

ENV CATALINA_HOME=/opt/tomcat

RUN dnf install -y python3 python3-jinja2 java-1.8.0-openjdk-devel && \
    groupadd -r -g 1001 tomcat && \
    useradd -r -u 1001 -g tomcat -m -d /opt/tomcat tomcat

COPY templates/*.j2 /opt/jinja-templates/

COPY --from=stage --chown=tomcat:tomcat /tmp/tomcat /opt/tomcat
USER tomcat
WORKDIR /opt/tomcat
EXPOSE 8080
CMD ["./entrypoint.sh"]