FROM node:lts
RUN apt-get update -y && apt-get install -y wget default-jre rsync

