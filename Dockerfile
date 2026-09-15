ARG BASE_IMAGE=0
FROM ${BASE_IMAGE}
LABEL maintainer="Nimbix, Inc."

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER
ENV SERIAL_NUMBER=${SERIAL_NUMBER}

ARG MAJOR_MINOR
ARG PATCH_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ARG JARVICE_DESKTOP_BRANCH=master
RUN if command -v dnf >/dev/null 2>&1; then \
        dnf install -y epel-release && crb enable && dnf install -y ca-certificates wget; \
    elif command -v apt-get >/dev/null 2>&1; then \
        apt-get -y update && \
        apt-get -y install ca-certificates curl --no-install-recommends; \
    fi && \
    curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/${JARVICE_DESKTOP_BRANCH}/install-nimbix.sh \
        | bash -s -- --jarvice-desktop-branch ${JARVICE_DESKTOP_BRANCH}

WORKDIR /opt/blender

# Download from a mirror site
COPY install-blender.sh /tmp/install-blender.sh
RUN /tmp/install-blender.sh ${MAJOR_MINOR} ${PATCH_VERSION}

COPY scripts /usr/local/scripts
COPY benchmark /opt/blender/benchmark

COPY NAE/AppDef.json /etc/NAE/AppDef.json
RUN sed -i s",BLENDER_VERSION,${MAJOR_MINOR}.${PATCH_VERSION}," /etc/NAE/AppDef.json
COPY NAE/screenshot.png /etc/NAE/screenshot.png
COPY NAE/license.txt /etc/NAE/license.txt
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate

# pull optimization best practice for JARVICE
RUN touch /etc/NAE/screenshot.png /etc/NAE/screenshot.txt /etc/NAE/license.txt /etc/NAE/AppDef.json /etc/NAE/swlicense.txt
