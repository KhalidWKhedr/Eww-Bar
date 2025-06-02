import sys
from actions import pair, connect, trust, battery
from generate_devices import generate_yuck_output
from logger import log

def main():
    if len(sys.argv) < 2:
        print("Usage: python main.py {pair|connect|trust|battery|scan|ui} <MAC_ADDRESS>")
        sys.exit(1)

    action = sys.argv[1]
    mac = sys.argv[2].upper() if len(sys.argv) > 2 else None

    match action:
        case "pair":
            if not mac: return print("MAC address required")
            pair.pair_device(mac)
        case "connect":
            if not mac: return print("MAC address required")
            connect.connect_device(mac)
        case "trust":
            if not mac: return print("MAC address required")
            trust.trust_device(mac)
        case "battery":
            if not mac: return print("MAC address required")
            print(battery.get_battery_level(mac))
        case "scan":
            from actions.scan import scan_devices
            print(scan_devices())
        case "ui":
            print(generate_yuck_output())
        case _:
            print(f"Unknown action: {action}")
            sys.exit(1)

if __name__ == "__main__":
    main()
