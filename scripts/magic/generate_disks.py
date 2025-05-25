import json

# Simulated input from `eww get EWW_DISK`
eww_disk_json = '''
{"/":{"free":58952560640,"name":{"Unix":[47,100,101,118,47,110,118,109,101,49,110,49,112,54]},"total":104552390656,"used":45599830016,"used_perc":43.61433410644531},"/boot/efi":{"free":203427840,"name":{"Unix":[47,100,101,118,47,110,118,109,101,49,110,49,112,49]},"total":268435456,"used":65007616,"used_perc":24.21722412109375},"/home":{"free":29078228992,"name":{"Unix":[47,100,101,118,47,110,118,109,101,49,110,49,112,55]},"total":139586437120,"used":110508208128,"used_perc":79.16830444335938},"/mnt/Media":{"free":633037471744,"name":{"Unix":[47,47,49,57,50,46,49,54,56,46,49,46,49,47,83,104,111,119,115,92,48,52,48,97,110,100,92,48,52,48,77,111,118,105,101,115]},"total":1128200663040,"used":495163191296,"used_perc":43.8896369934082}}
'''

data = json.loads(eww_disk_json)

def path_to_widget_name(path):
    # Map path to widget name
    if path == "/":
        return "disk_root"
    elif path == "/boot/efi":
        return "disk_boot_efi"
    elif path == "/home":
        return "disk_home"
    elif path == "/mnt/Media":
        return "disk_mnt_Media"
    else:
        name = path.strip("/").replace("/", "_")
        return f"disk_{name}"

for path, info in data.items():
    widget_name = path_to_widget_name(path)
    json_path = path.replace('"', '\\"')  # escape quotes if any
    print(f'''(defwidget {widget_name} []
  (base_resource_circular
    :icon "󰋊"
    :tooltip EWW_DISK."{json_path}".tooltip
    :value EWW_DISK."{json_path}".used_perc
    :label_text EWW_DISK."{json_path}".label_text
    :label_style ""
    :box_class "magic_{widget_name}_box"
    :circular_progress_class "magic_{widget_name}_progress"
    :button_class "magic_{widget_name}_button"
    :button_style "font-size: 16px; margin-left: 7px"
    :label_class "magic_{widget_name}_label"))\n''')
