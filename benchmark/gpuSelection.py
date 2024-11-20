import bpy
import sys

# Copyright (c) 2024, Nimbix, Inc.
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

def enable_gpus(numCpus, numGpus):

    print("Running CPU/GPU Selection")

    numCpus = int(numCpus)
    numGpus = int(numGpus)

    preferences = bpy.context.preferences
    cycles_preferences = preferences.addons["cycles"].preferences
    cycles_preferences.refresh_devices()
    devices = cycles_preferences.devices
    device_type = "CUDA"

    if not devices:
        raise RuntimeError("Unsupported device type")

    activated_gpus = []
    curNumGpu = 0
    for device in devices:
        if device.type == "CPU":
            device.use = (numCpus > 0)
        else:
            if not (curNumGpu < numGpus):
                continue
            curNumGpu += 1
            device.use = True
            activated_gpus.append(device.name)
        if device.use:
            print(f'Activated {device.type}: {device.name}')

    cycles_preferences.compute_device_type = device_type
    bpy.context.scene.cycles.device = "GPU"

    return activated_gpus


enable_gpus(sys.argv[-2], sys.argv[-1])
