FROM debian:11.5-slim

LABEL org.opencontainers.image.vendor="Swiss GRC AG"
LABEL org.opencontainers.image.authors="Swiss GRC AG <opensource@swissgrc.com>"
LABEL org.opencontainers.image.title="azure-pipelines-openjdk"
LABEL org.opencontainers.image.documentation="https://github.com/swissgrc/docker-azure-pipelines-openjdk"

# Make sure to fail due to an error at any stage in shell pipes
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Install Docker CLI

# renovate: datasource=github-tags depName=docker/cli extractVersion=^v(?<version>.*)$
ENV DOCKERCLI_VERSION=20.10.20
#Disabled renovate: datasource=repology depName=debian_11/curl versioning=loose
ENV CURL_VERSION=7.74.0-1.3+deb11u3
#Disabled renovate: datasource=repology depName=debian_11/ca-certificates versioning=loose
ENV CACERTIFICATES_VERSION=20210119
#Disabled renovate: datasource=repology depName=debian_11/lsb-release versioning=loose
ENV LSBRELEASE_VERSION=11.1.0
#Disabled renovate: datasource=repology depName=debian_11/gnupg2 versioning=loose
ENV GNUPG_VERSION=2.2.27-2+deb11u2

RUN apt-get update -y && \
  # Install necessary dependencies
  apt-get install -y --no-install-recommends ca-certificates=${CACERTIFICATES_VERSION} curl=${CURL_VERSION} lsb-release=${LSBRELEASE_VERSION} gnupg=${GNUPG_VERSION} && \
  # Add Dockers public key
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
  # Add Dockers APT repository to the list of sources
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
  # Update the package sources
  apt-get update -y && \
  # Install Docker CLI
  apt-get install -y --no-install-recommends docker-ce-cli=5:${DOCKERCLI_VERSION}~3-0~debian-bullseye && \
  # Clean up
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # Smoke test
  docker --version

# Install OpenJDK

# renovate: datasource=adoptium-java depName=java-jdk versioning=loose
ENV OPENJDK_VERSION=17.0.4.0.0+8

RUN apt-get update -y && \
  # Add Eclipse Adoptium public key
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public | tee /etc/apt/keyrings/adoptium.asc && \
  # Add Eclipse Adoptium APT repository to the list of sources
  echo "deb [signed-by=/etc/apt/keyrings/adoptium.asc] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list > /dev/null && \
  # Update the package sources
  apt-get update -y && \
  # Install OpenJDK
  apt-get install -y --no-install-recommends temurin-17-jdk=${OPENJDK_VERSION} && \
  # Clean up
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # Smoke test
  java -version
