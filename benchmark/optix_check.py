import bpy
import sys

# Function to check if OptiX is available
def is_optix_available():
    prefs = bpy.context.preferences
    cprefs = prefs.addons['cycles'].preferences
    cprefs.get_devices()
    # devices=""
    device_names=list()
    device_types=list()
    for device in cprefs.devices:
        # devices+=f" {device.type}"
        device_types.append(device.type)
        device_names.append(device.name)
        # if 'OPTIX' in device.type:
        #     return True
    return device_types, device_names

def main():
    device_types, device_names = is_optix_available()
    if sys.argv[-1] == "DeviceTypes":
        # Running the function and printing the result
        print("Available Devices:", ' '.join(device_types))
    elif sys.argv[-1] == "DeviceNames":
        # get max length of dt first
        ml = 0
        for dt in device_types:
            if (cml := len(dt)) > ml:
                ml = cml
        for dt, dn in zip(device_types, device_names):
            print(f"      Found: {dt:>{ml}s}: {dn}")

if __name__ == "__main__":
    main()
