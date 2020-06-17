
GPU_COUNT=$1

mkdir -p /data/AppConfig/blender
mkdir -p "$HOME"/.config

ln -sf /data/AppConfig/blender "$HOME"/.config/blender

export TMP=/tmp
export TMPDIR=/tmp

if [ "$GPU_COUNT" -lt 1 ]; then
    SOFTWARE_RENDER="-softwaregl"
    export SOFTWARE_RENDER
fi
