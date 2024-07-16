#!/usr/bin/env bash
# Copyright (c) 2023, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.


# Source the JARVICE job environment variables
[[ -r /etc/JARVICE/jobenv.sh ]] && source /etc/JARVICE/jobenv.sh
[[ -r /etc/JARVICE/jobinfo.sh ]] && source /etc/JARVICE/jobinfo.sh

mkdir -p /data/AppConfig/blender
mkdir -p "$HOME"/.config
ln -sf /data/AppConfig/blender "$HOME"/.config/blender

set -e

[[ -z "$JOB_NAME" ]] && JOB_NAME="local" || true
CASE="/data/app-benchmarks/blender/benchmark-${JOB_NAME}"
if [[ -d "$CASE" ]]; then
  rm -r $CASE
fi
STARTING_DIRECTORY=${PWD}
mkdir -p $CASE
cd $CASE

BLENDER_FILE_LOCATION="/opt/blender/benchmark/render_files"

RENDER_FILE=""
USE_CPU="false"
USE_GPU="true"
NUM_GPU="0"
while [[ -n "$1" ]]; do
    case "$1" in
    -renderFile)
        shift
        RENDER_FILE="$1"
        ;;
    -enableCPU)
        USE_CPU="true"
        ;;
    -disableGPU)
        USE_GPU="false"
        ;;
    -gpucount)
        shift
        NUM_GPU="$1"
        ;;
    *)
        echo "ERROR: Invalid argument: $1" >&2
        exit 1
        ;;
    esac
    shift
done

if [[ $USE_CPU == "false" && $USE_GPU == "false" ]]; then
    echo "ERROR: Both CPU and GPU disabled..."
    echo "       Stopping..."
    exit 1
fi

if [[ $USE_GPU == "true" && $NUM_GPU == "0" ]]; then
    echo "WARNING: No GPU detected and GPU rendering was selected."
    echo "         Defaulting to CPU rendering."
    USE_CPU="true"
    USE_GPU="false"
fi

echo "INFO: Enabling Cycle Device(s)"
CYCLE_DEVICE=""
if [[ $USE_GPU == "true" ]]; then
    AVAILABLE_DEVICES=$(/opt/blender/blender -b -P /opt/blender/benchmark/optix_check.py | grep -- "Available Devices:")
    if [[ "$AVAILABLE_DEVICES" =~ "OPTIX" ]]; then
        CYCLE_DEVICE="OPTIX"
    elif [[ "$AVAILABLE_DEVICES" =~ "CUDA" ]]; then
        CYCLE_DEVICE="CUDA"
    elif [[ "$AVAILABLE_DEVICES" =~ "HIP" ]]; then
        CYCLE_DEVICE="HIP"
    fi
fi

if [[ $USE_CPU == "true" ]]; then
    if [[ -n $CYCLE_DEVICE ]]; then
        CYCLE_DEVICE="$CYCLE_DEVICE+CPU"
    else
        CYCLE_DEVICE="CPU"
    fi
fi
echo "INFO: Found $CYCLE_DEVICE"

DEBUG_LOGS=""
if [[ -n "$DEBUG_CYCLES" ]]; then
    DEBUG_LOGS="$DEBUG_LOGS --debug-cycles"
fi

if [[ -n "$DEBUG_GPU" ]]; then
    DEBUG_LOGS="$DEBUG_LOGS --debug-gpu"
fi

if [[ $DEBUG_LOGS ]]; then
    DEBUG_LOGS="-d $DEBUG_LOGS"
fi

echo "INFO: Using $RENDER_FILE" | tee -a benchmark.log

stime=$(date '+%s%3N')

cmd="\
/opt/blender/blender \
--factory-startup \
--background \
${BLENDER_FILE_LOCATION}/${RENDER_FILE}.blend \
--render-output test_ \
--engine CYCLES \
$DEBUG_LOGS \
--render-format PNG \
--use-extension 1 \
--render-frame 1 \
-- --cycles-device $CYCLE_DEVICE"

echo "Running: $cmd"
eval $cmd
ERR=$?

etime=$(date '+%s%3N')
if [[ $ERR -gt 0 ]]; then
    echo "BENCHMARK INFO: Render experienced an error..."
    echo "STATUS: $ERR"
    exit $ERR
fi
dt_solver=$((etime-stime))
dt_solver_seconds=$(perl -e "print int(100*$dt_solver/1000 + 0.5)/100")
SOLVER_SCORE=$(perl -e "print int(8640000000.0/$dt_solver+0.99)/100")

echo "INFO: Render finished in ${dt_solver_seconds} seconds" | tee -a benchmark.log
echo "INFO: Render Score = ${SOLVER_SCORE}" | tee -a benchmark.log

# Python script is not setting the correct number of gpus to use.
# ,
# "-maxNumGpu": {
#     "name": "-maxNumGpu",
#     "type": "INT",
#     "required": false,
#     "positional": false,
#     "value": 0,
#     "min": 0,
#     "max": 64,
#     "description": "Set the max number of GPUs to use."
# }
