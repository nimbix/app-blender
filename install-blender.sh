#!/usr/bin/env bash

MAJOR_MINOR="$1"
PATCH_VERSION="$2"

MIRRORS="
https://download.blender.org/release/Blender${MAJOR_MINOR}/blender-${MAJOR_MINOR}.${PATCH_VERSION}-linux-x64.tar.xz
https://mirrors.ocf.berkeley.edu/blender/release/Blender${MAJOR_MINOR}/blender-${MAJOR_MINOR}.${PATCH_VERSION}-linux-x64.tar.xz
https://mirror.clarkson.edu/blender/release/Blender${MAJOR_MINOR}/blender-${MAJOR_MINOR}.${PATCH_VERSION}-linux-x64.tar.xz
"

FOUND_APP=FALSE
for mirror in $MIRRORS; do
    echo "Trying $mirror"
    curl -L $mirror | tar xJ --strip-components=1
    ERROR_CODE=$?
    echo "ERROR CODE: $ERROR_CODE"
done

if [[ $ERROR_CODE != "0" ]]; then
    echo "ERROR: FAILED TO DOWNLOAD FILE"
    exit 255
fi
