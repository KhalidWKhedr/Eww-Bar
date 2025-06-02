#!/usr/bin/env python3
import os
import re
import subprocess
import time
import logging
from pathlib import Path

class BluetoothDeviceGenerator:
    def __init__(self):
        self.home = os.path.expanduser("~")
        self.log_file = "/var/log/bluetooth_generate_devices.log"
        self.lock_file = "/tmp/generate_devices.lock"
        self._setup_logging()
        self.logger = logging.getLogger("bluetooth_device_generator")

    def _setup_logging(self):
        """Configure logging with fallback to home directory"""
        try:
            Path(self.log_file).touch()
            Path(self.log_file).chmod(0o644)
        except PermissionError:
            self.log_file = f"{self.home}/.cache/bluetooth_generate_devices.log"
            Path(self.log_file).touch()
        
        logging.basicConfig(
            filename=self.log_file,
            level=logging.INFO,
            format='[%(asctime)s] %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )

    def _acquire_lock(self):
        """Prevent concurrent execution using lock file"""
        if Path(self.lock_file).exists():
            self.logger.warning("Scanning already in progress - exiting")
            return False
            
        Path(self.lock_file).touch()
        self.logger.info("Created lockfile")
        return True

    def _release_lock(self):
        """Release execution lock"""
        try:
            Path(self.lock_file).unlink()
            self.logger.info("Removed lockfile")
        except FileNotFoundError:
            pass

    def _check_bluetooth_service(self):
        """Verify Bluetooth service is active"""
        if subprocess.run(["systemctl", "is-active", "bluetooth"], 
                         capture_output=True).returncode != 0:
            self.logger.error("Bluetooth service not running")
            return False
        self.logger.info("Bluetooth service is active")
        return True

    def _check_bluetooth_powered(self):
        """Verify Bluetooth is powered on"""
        result = subprocess.run(["bluetoothctl", "show"], 
                              capture_output=True, text=True)
        if "Powered: yes" not in result.stdout:
            self.logger.error("Bluetooth is powered off")
            return False
        self.logger.info("Bluetooth is powered on")
        return True

    def _scan_devices(self):
        """Scan for Bluetooth devices and return list"""
        self.logger.info("Starting Bluetooth scan")
        subprocess.run(["bluetoothctl", "scan", "on"], 
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(3)
        subprocess.run(["bluetoothctl", "scan", "off"], 
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        self.logger.info("Bluetooth scan completed")
        
        # Get paired devices
        result = subprocess.run(["bluetoothctl", "devices"], 
                              capture_output=True, text=True)
        return result.stdout

    def _parse_devices(self, device_list):
        """Parse device list into (mac, name) tuples"""
        devices = []
        for line in device_list.splitlines():
            if not line.startswith("Device "):
                continue
            parts = line.split(maxsplit=2)
            if len(parts) < 3:
                continue
            mac = parts[1].upper()
            name = parts[2].strip()
            devices.append((mac, name))
        return devices

    def _escape_yuck(self, text):
        """Escape special characters for Yuck format"""
        text = re.sub(r'["()]', lambda m: '\\' + m.group(), text)
        # Remove non-printable characters
        return ''.join(c for c in text if 32 <= ord(c) < 127).strip()

    def generate_device_list(self):
        """Main entry point: generate Yuck formatted device list"""
        self.logger.info("Starting Bluetooth device generation")
        
        if not self._acquire_lock():
            return '(label :text "Scanning in progress, please wait")'
        
        try:
            if not self._check_bluetooth_service():
                return '(label :text "Error: Bluetooth service not running")'
                
            if not self._check_bluetooth_powered():
                return '(label :text "Error: Bluetooth is powered off")'
            
            device_output = self._scan_devices()
            devices = self._parse_devices(device_output)
            
            if not devices:
                self.logger.warning("No Bluetooth devices found")
                return '(label :text "No Bluetooth devices found")'
            
            self.logger.info(f"Found {len(devices)} devices")
            return self._generate_yuck(devices)
            
        finally:
            self._release_lock()

    def _generate_yuck(self, devices):
        """Generate Yuck UI elements for devices"""
        output = ['(box :orientation "v" :space-evenly "true"']
        
        for mac, name in devices:
            safe_name = self._escape_yuck(name)
            if not safe_name:
                self.logger.warning(f"Skipping device with empty name (MAC: {mac})")
                continue
                
            self.logger.info(f"Processing device: {safe_name} ({mac})")
            
            device_block = f'''
 (box :class "container_devices" :orientation "h" :space-evenly "true"
   (button :class "device_name" :style "font-size: 14px; padding-left: 0px"
           :onclick "{self.home}/.config/eww/scripts/popup audio \\"{safe_name}\\""
           "{safe_name}")
   (box :class "container_options" :orientation "h" :space-evenly "true" :valign "center"
     (button :class "bluetooth_link" :style "font-size: 15px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth/device_controller/main.sh pair \\"{mac}\\""
             "")
     (button :class "bluetooth_connect" :style "font-size: 20px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth/device_controller/main.sh connect \\"{mac}\\""
             "󰂱")
     (button :class "bluetooth_trust" :style "font-size: 15px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth/device_controller/main.sh trust \\"{mac}\\""
             "")))'''
            
            output.append(device_block)
        
        output.append(')')
        self.logger.info("Completed Bluetooth device generation")
        return '\n'.join(output)

# Example usage when run directly
if __name__ == "__main__":
    generator = BluetoothDeviceGenerator()
    print(generator.generate_device_list())