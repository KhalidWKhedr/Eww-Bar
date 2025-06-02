import subprocess
import time
import os
from config import SCAN_DURATION, LOCKFILE_PATH
from logger import log

def is_bluetooth_active():
    return subprocess.run(['systemctl', 'is-active', '--quiet', 'bluetooth']).returncode == 0

def is_bluetooth_powered():
    result = subprocess.run(['bluetoothctl', 'show'], capture_output=True, text=True)
    return "Powered: yes" in result.stdout

def scan_devices():
    if os.path.exists(LOCKFILE_PATH):
        log("Scan already in progress", "warning")
        return "SCAN_IN_PROGRESS"

    try:
        open(LOCKFILE_PATH, 'w').close()
        log("Created lockfile")

        if not is_bluetooth_active():
            log("Bluetooth service inactive", "error")
            return "BLUETOOTH_SERVICE_INACTIVE"

        if not is_bluetooth_powered():
            log("Bluetooth is powered off", "error")
            return "BLUETOOTH_POWERED_OFF"

        log("Starting Bluetooth scan", "info")
        subprocess.run(['bluetoothctl', 'scan', 'on'], stdout=subprocess.DEVNULL)
        time.sleep(SCAN_DURATION)
        subprocess.run(['bluetoothctl', 'scan', 'off'], stdout=subprocess.DEVNULL)

        result = subprocess.run(['bluetoothctl', 'devices'], capture_output=True, text=True)
        devices = []

        for line in result.stdout.strip().split('\n'):
            if line.startswith("Device"):
                parts = line.split(' ', 2)
                mac = parts[1].upper()
                name = parts[2].strip()
                devices.append((mac, name))

        if not devices:
            log("No devices found", "info")
            return []

        log(f"Found {len(devices)} devices", "info")
        return devices

    finally:
        if os.path.exists(LOCKFILE_PATH):
            os.remove(LOCKFILE_PATH)
            log("Removed lockfile", "info")
