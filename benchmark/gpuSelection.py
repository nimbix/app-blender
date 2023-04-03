import bpy
import sys

def enable_gpus(numCpus,numGpus):

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
            print('activated gpu', device.name)

    cycles_preferences.compute_device_type = device_type
    bpy.context.scene.cycles.device = "GPU"

    return activated_gpus


enable_gpus(sys.argv[-2], sys.argv[-1])
