FROM ubuntu:jammy
LABEL maintainer="Nimbix, Inc."

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20230721.1000}

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates curl --no-install-recommends && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

WORKDIR /opt/blender

# Download from a mirror site
RUN curl -o blender.tgz https://mirrors.ocf.berkeley.edu/blender/release/Blender3.6/blender-3.6.1-linux-x64.tar.xz && \
    tar xf blender.tgz --strip-components=1 && \
    rm -f blender.tgz

COPY scripts /usr/local/scripts
COPY benchmark /opt/blender/benchmark

COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate

COPY NAE/screenshot.png /etc/NAE/screenshot.png

# pull optimization best practice for JARVICE
RUN touch /etc/NAE/screenshot.png /etc/NAE/screenshot.txt /etc/NAE/license.txt /etc/NAE/AppDef.json
