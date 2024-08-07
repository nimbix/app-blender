FROM ubuntu:22.04
LABEL maintainer="Nimbix, Inc."

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER=${SERIAL_NUMBER}

ARG MAJOR_MINOR
ARG PATCH_VERSION

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install ca-certificates curl --no-install-recommends && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

WORKDIR /opt/blender

# Download from a mirror site
ARG URL=https://mirror.clarkson.edu/blender/release/Blender${MAJOR_MINOR}/blender-${MAJOR_MINOR}.${PATCH_VERSION}-linux-x64.tar.xz
RUN curl -o blender.tgz URL && \
    tar xf blender.tgz --strip-components=1 && \
    rm -f blender.tgz

COPY scripts /usr/local/scripts
COPY benchmark /opt/blender/benchmark

COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate

COPY NAE/screenshot.png /etc/NAE/screenshot.png

# pull optimization best practice for JARVICE
RUN touch /etc/NAE/screenshot.png /etc/NAE/screenshot.txt /etc/NAE/license.txt /etc/NAE/AppDef.json
