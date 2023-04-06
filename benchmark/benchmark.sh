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

set -e

[[ -z "$JOB_NAME" ]] && JOB_NAME="local" || true
CASE="/data/app-benchmarks/blender/benchmark-${JOB_NAME}"
if [[ -d "$CASE" ]]; then
  rm -r $CASE
fi
STARTING_DIRECTORY=${PWD}
mkdir -p $CASE
cd $CASE

BLENDER_FILE_LOCATION="/opt/blender/benchmark/render_files/"

RENDER_FILE=""
USE_CPU="false"
NUM_CPU=0
USE_GPU="true"
NUM_GPU=0
MAX_NUM_GPU=0
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
    -maxNumGpu)
        shift
        MAX_NUM_GPU="$1"
        ;;
    *)
        echo "Invalid argument: $1" >&2
        exit 1
        ;;
    esac
    shift
done

if [[ $USE_CPU == "false" && $USE_GPU == "false" ]]; then
    echo "Both CPU and GPU disabled..."
    echo "Stopping..."
    exit 1
fi

if [[ $USE_CPU == "true" ]]; then
    NUM_CPU=1
fi

if [[ $MAX_NUM_GPU -gt 0 && $MAX_NUM_GPU -lt $NUM_GPU ]]; then
    NUM_GPU=$MAX_NUM_GPU
fi

if [[ $USE_GPU == "false" ]]; then
    NUM_GPU=0
fi

echo "Using $RENDER_FILE" | tee -a benchmark.log

stime=$(date '+%s%3N')
set -x
/opt/blender/blender \
    --background \
    -P /opt/blender/benchmark/gpuSelection.py \
    ${BLENDER_FILE_LOCATION}/${RENDER_FILE}.blend \
    --render-output test_ \
    --engine CYCLES \
    --render-format PNG \
    --use-extension 1 \
    --render-frame 1 \
    -- $NUM_CPU $NUM_GPU | tee -a benchmark.log
ERR=$?
set +x
etime=$(date '+%s%3N')
if [[ $ERR -gt 0 ]]; then
    echo "BENCHMARK INFO: Render experienced an error..."
    echo "STATUS: $ERR"
    exit $ERR
fi
dt_solver=$((etime-stime))
dt_solver_seconds=$(perl -e "print int(100*$dt_solver/1000 + 0.5)/100")
SOLVER_SCORE=$(perl -e "print int(8640000000.0/$dt_solver+0.99)/100")

echo "BENCHMARK INFO: Render finished in ${dt_solver_seconds} seconds" | tee -a benchmark.log
echo "BENCHMARK INFO: Render Score = ${SOLVER_SCORE}" | tee -a benchmark.log
