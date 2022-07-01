
GPU_COUNT=$1

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
