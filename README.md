# app-blender

https://www.blender.org/

Blender is the free and open source 3D creation suite. 
It supports the entirety of the 3D pipeline—modeling, rigging, animation, 
simulation, rendering, compositing and motion tracking, video editing and 2D animation pipeline.

Note that base64 encoded script content is:

```bash
#!/bin/bash

## TODO: Use slave.blend config and start on other hosts in cluster
# for network rendering

SOFTWARE_RENDER=

mkdir -p /data/AppConfig/blender
mkdir -p "$HOME"/.config

ln -sf /data/AppConfig/blender "$HOME"/.config/blender

[ -f /etc/JARVICE/vglinfo.sh ] && . /etc/JARVICE/vglinfo.sh || true

export TMP=/tmp
export TMPDIR=/tmp

if [ -z "$VGL_DISPLAY" ]; then
    SOFTWARE_RENDER="-softwaregl"
    export SOFTWARE_RENDER
fi

# start the GUI with the GPU renderer enabled or the software rendering version
exec /opt/blender/blender${SOFTWARE_RENDER} -noaudio
```
