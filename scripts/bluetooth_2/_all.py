#!/usr/bin/env python3
import os
import re
import subprocess
import time
import logging
import dbus
from pathlib import Path
from datetime import datetime

class BluetoothManager:
    def __init__(self):
        self.home = os.path.expanduser("~")
        self.log_file = f"{self.home}/.cache/bluetooth_manager.log"
        self.lock_file = "/tmp/bluetooth_manager.lock"
        self._setup_logging()
        self.logger = logging.getLogger("bluetooth_manager")
        self.logger.info("BluetoothManager initialized")

    def _setup_logging(self):
        """Configure logging with fallback to home directory"""
        try:
            Path(self.log_file).touch()
            Path(self.log_file).chmod(0o644)
        except PermissionError:
            self.log_file = f"{self.home}/.cache/bluetooth_manager.log"
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
            self.logger.warning("Operation already in progress - exiting")
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

    def _run_bluetooth_command(self, command, mac=None):
        """Execute bluetoothctl commands safely"""
        try:
            if mac:
                cmd = ["bluetoothctl"] + command + [mac]
            else:
                cmd = ["bluetoothctl"] + command
                
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=10
            )
            self.logger.debug(f"Command: {' '.join(cmd)}")
            self.logger.debug(f"Output: {result.stdout.strip()}")
            self.logger.debug(f"Error: {result.stderr.strip()}")
            
            return result.stdout
        except subprocess.TimeoutExpired:
            self.logger.error("Bluetooth command timed out")
            return ""
        except Exception as e:
            self.logger.error(f"Error executing command: {str(e)}")
            return ""

    def scan_devices(self):
        """Scan for Bluetooth devices and return list"""
        if not self._acquire_lock():
            return []
            
        try:
            if not self._check_bluetooth_service():
                return []
                
            if not self._check_bluetooth_powered():
                return []
            
            self.logger.info("Starting Bluetooth scan")
            self._run_bluetooth_command(["scan", "on"])
            time.sleep(5)
            self._run_bluetooth_command(["scan", "off"])
            self.logger.info("Bluetooth scan completed")
            
            # Get discovered devices
            devices_output = self._run_bluetooth_command(["devices"])
            return self._parse_devices(devices_output)
        finally:
            self._release_lock()

    def get_paired_devices(self):
        """Get list of paired devices"""
        self.logger.info("Fetching paired devices")
        paired_output = self._run_bluetooth_command(["paired-devices"])
        return self._parse_devices(paired_output)

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

    def get_device_info(self, mac):
        """Get detailed information about a device"""
        self.logger.info(f"Fetching device info for {mac}")
        info = self._run_bluetooth_command(["info"], mac)
        return info

    def get_battery_level(self, mac):
        """Get battery level for a device"""
        self.logger.info(f"Checking battery level for {mac}")
        info = self.get_device_info(mac)
        
        # Parse battery information
        battery_level = "N/A"
        for line in info.splitlines():
            if "Battery Percentage" in line:
                match = re.search(r'\((\d+)\)', line)
                if match:
                    battery_level = f"{match.group(1)}%"
                    break
        return battery_level

    def connect(self, mac):
        """Connect to a Bluetooth device"""
        self.logger.info(f"Connecting to device {mac}")
        result = self._run_bluetooth_command(["connect"], mac)
        if "Connection successful" in result:
            self.logger.info(f"Successfully connected to {mac}")
            return True
        self.logger.error(f"Failed to connect to {mac}")
        return False

    def disconnect(self, mac):
        """Disconnect from a Bluetooth device"""
        self.logger.info(f"Disconnecting from device {mac}")
        result = self._run_bluetooth_command(["disconnect"], mac)
        if "Successful disconnected" in result:
            self.logger.info(f"Successfully disconnected from {mac}")
            return True
        self.logger.error(f"Failed to disconnect from {mac}")
        return False

    def pair(self, mac):
        """Pair with a Bluetooth device"""
        self.logger.info(f"Pairing with device {mac}")
        result = self._run_bluetooth_command(["pair"], mac)
        if "Pairing successful" in result:
            self.logger.info(f"Successfully paired with {mac}")
            return True
        self.logger.error(f"Failed to pair with {mac}")
        return False

    def trust(self, mac):
        """Trust a Bluetooth device"""
        self.logger.info(f"Trusting device {mac}")
        result = self._run_bluetooth_command(["trust"], mac)
        if "trust succeeded" in result.lower():
            self.logger.info(f"Successfully trusted {mac}")
            return True
        self.logger.error(f"Failed to trust {mac}")
        return False

    def remove(self, mac):
        """Remove a Bluetooth device"""
        self.logger.info(f"Removing device {mac}")
        result = self._run_bluetooth_command(["remove"], mac)
        if "Device has been removed" in result:
            self.logger.info(f"Successfully removed {mac}")
            return True
        self.logger.error(f"Failed to remove {mac}")
        return False

    def _escape_yuck(self, text):
        """Escape special characters for Yuck format"""
        text = re.sub(r'["()]', lambda m: '\\' + m.group(), text)
        # Remove non-printable characters
        return ''.join(c for c in text if 32 <= ord(c) < 127).strip()

    def generate_device_list(self):
        """Generate Yuck formatted device list for EWW"""
        self.logger.info("Generating device list for UI")
        try:
            devices = self.scan_devices()
            if not devices:
                return '(label :text "No Bluetooth devices found")'
            
            output = ['(box :orientation "v" :space-evenly "true"']
            
            for mac, name in devices:
                safe_name = self._escape_yuck(name)
                if not safe_name:
                    continue
                    
                device_block = f'''
 (box :class "container_devices" :orientation "h" :space-evenly "true"
   (button :class "device_name" :style "font-size: 14px; padding-left: 0px"
           :onclick "{self.home}/.config/eww/scripts/popup audio \\"{safe_name}\\""
           "{safe_name}")
   (box :class "container_options" :orientation "h" :space-evenly "true" :valign "center"
     (button :class "bluetooth_link" :style "font-size: 15px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth_manager.py pair {mac}"
             "")
     (button :class "bluetooth_connect" :style "font-size: 20px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth_manager.py connect {mac}"
             "󰂱")
     (button :class "bluetooth_trust" :style "font-size: 15px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth_manager.py trust {mac}"
             "")
     (button :class "bluetooth_remove" :style "font-size: 15px; padding-left: 0px"
             :onclick "{self.home}/.config/eww/scripts/bluetooth_manager.py remove {mac}"
             "")))'''
                
                output.append(device_block)
            
            output.append(')')
            return '\n'.join(output)
        except Exception as e:
            self.logger.error(f"Error generating device list: {str(e)}")
            return '(label :text "Error generating device list")'

# Command line interface
if __name__ == "__main__":
    import sys
    manager = BluetoothManager()
    
    if len(sys.argv) == 1:
        print(manager.generate_device_list())
    elif len(sys.argv) >= 3:
        action = sys.argv[1]
        mac = sys.argv[2].upper()
        
        if action == "connect":
            manager.connect(mac)
        elif action == "pair":
            manager.pair(mac)
        elif action == "trust":
            manager.trust(mac)
        elif action == "remove":
            manager.remove(mac)
        elif action == "battery":
            print(manager.get_battery_level(mac))
        else:
            manager.logger.error(f"Invalid action: {action}")
    else:
        manager.logger.error("Invalid arguments")
        print("Usage:")
        print("  ./bluetooth_manager.py [action] [mac_address]")
        print("Actions: connect, pair, trust, remove, battery")
        print("To generate device list: ./bluetooth_manager.py")