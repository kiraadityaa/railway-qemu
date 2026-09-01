# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute

ARG BUILD_DATE
ARG VERSION
ARG XFCE_VERSION

LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

ENV TITLE="Ubuntu XFCE"

RUN \
  echo "**** add icon ****" && \
  curl -L \
    -o /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/webtop-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    adwaita-icon-theme \
    chromium \
    mousepad \
    ristretto \
    thunar \
    util-linux \
    xfce4 \
    xfce4-terminal \
    xfce4-goodies \
    && \
  echo "**** xfce-tweaks ****" && \
  if [ -f /usr/bin/thunar ]; then \
    mv /usr/bin/thunar /usr/bin/thunar-real; \
  fi && \
  echo "**** cleanup ****" && \
  rm -f \
    /etc/xdg/autostart/xfce4-power-manager.desktop \
    /etc/xdg/autostart/xscreensaver.desktop \
    /usr/share/xfce4/panel/plugins/power-manager-plugin.desktop && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /var/lib/apt/lists/* \
    /config/.cache \
    /tmp/*

EXPOSE 3001
