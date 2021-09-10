FROM ghcr.io/linuxserver/baseimage-alpine:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG WIKIJS_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="alex-phillips"

# environment settings
ENV HOME="/app"
ENV NODE_ENV="production"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache \
    alpine-base \
    git \
    nodejs \
    npm \
    openssh && \
  apk add --no-cache --virtual=build-dependencies \
    curl \
    g++ \
    make \
    python3 && \
  echo "**** symlink python3 for compatibility ****" && \
  ln -s /usr/bin/python3 /usr/bin/python && \
  echo "**** install wiki.js ****" && \
  mkdir -p /app/wiki && \
  if [ -z ${WIKIJS_RELEASE} ]; then \
    WIKIJS_RELEASE=$(curl -sX GET "https://api.github.com/repos/Requarks/wiki/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/wiki.tar.gz -L \
    "https://github.com/Requarks/wiki/releases/download/${WIKIJS_RELEASE}/wiki-js.tar.gz" && \
  tar xf \
    /tmp/wiki.tar.gz -C \
    /app/wiki/ && \
  cd /app/wiki && \
  npm rebuild sqlite3 && \
  echo "**** overlay-fs bug workaround ****" && \
  mv /app/wiki /app/wiki-tmp && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root/.cache \
    /tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 3000
