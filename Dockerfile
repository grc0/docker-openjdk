FROM node:lts

# Make sure to fail due to an error at any stage in shell pipes
SHELL ["/bin/bash", "-o", "pipefail", "-c"]


RUN apt-get update -y && apt-get install -y wget default-jre rsync
RUN wget https://github.com/gohugoio/hugo/releases/download/v0.103.0/hugo_0.103.0_linux-amd64.deb
RUN dpkg -i hugo*.deb
RUN rm hugo*.deb


  # Smoke test
  java -version
