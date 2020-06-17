#!/bin/bash

## TODO: Use slave.blend config and start on other hosts in cluster
# for network rendering

while [ -n "$1" ]; do
  case "$1" in
  -gpus)
    shift
    GPU_COUNT="$1"
    ;;
  *) ;;
  esac
  shift
done

SOFTWARE_RENDER=

. $(dirname "$0")/setenv.sh "$GPU_COUNT"

exec /opt/blender/blender${SOFTWARE_RENDER} -W -noaudio
