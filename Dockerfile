FROM ubuntu:bionic
LABEL maintainer="Nimbix, Inc."

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20200616.1800}

RUN apt-get -y update && \
    apt-get -y install curl ca-certificates && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
        | bash -s -- --setup-nimbix-desktop

WORKDIR /opt/blender

# Download from a mirror site
RUN curl -o blender.tgz https://mirror.clarkson.edu/blender/release/Blender2.83/blender-2.83.0-linux64.tar.xz && \
    tar xf blender.tgz --strip-components=1 && \
    rm -f blender.tgz

COPY scripts /usr/local/scripts

COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

COPY NAE/screenshot.png /etc/NAE/screenshot.png
