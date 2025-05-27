#!/usr/bin/env python3

import json
import time
import subprocess
import logging
import signal
import sys
import os
from pathlib import Path
from typing import Optional, Dict, Any
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
from concurrent.futures import ThreadPoolExecutor
from functools import partial

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S',
    handlers=[
        logging.FileHandler(Path.home() / ".cache/eww_notification_watcher.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Constants
NOTIF_PATH = Path.home() / ".cache/eww_notifications.json"
MAX_RETRIES = 3
RETRY_DELAY = 1.0
UPDATE_COOLDOWN = 0.1  # Minimum time between updates
MAX_NOTIFICATIONS = 10  # Maximum number of notifications to keep

class NotificationManager:
    def __init__(self):
        self.last_update_time = 0
        self.current_notifications: Dict[str, Any] = {}
        self.executor = ThreadPoolExecutor(max_workers=1)
        self._setup_signal_handlers()

    def _setup_signal_handlers(self):
        """Set up signal handlers for graceful shutdown."""
        signal.signal(signal.SIGINT, self._handle_shutdown)
        signal.signal(signal.SIGTERM, self._handle_shutdown)

    def _handle_shutdown(self, signum, frame):
        """Handle shutdown signals gracefully."""
        logger.info(f"Received signal {signum}, shutting down...")
        self.executor.shutdown(wait=True)
        sys.exit(0)

    def update_eww_widget(self, notifications: list) -> None:
        """Update the Eww widget with new notifications."""
        current_time = time.time()
        if current_time - self.last_update_time < UPDATE_COOLDOWN:
            return

        def _update():
            try:
                # Limit number of notifications
                notifications_to_show = notifications[:MAX_NOTIFICATIONS]
                
                # Update Eww widget
                subprocess.run(
                    ['eww', 'update', f'notifications={json.dumps(notifications_to_show)}'],
                    check=True,
                    capture_output=True,
                    text=True
                )
                self.last_update_time = time.time()
                logger.debug("Updated Eww notifications widget")
            except subprocess.CalledProcessError as e:
                logger.error(f"Failed to update Eww widget: {e.stderr}")
            except Exception as e:
                logger.error(f"Unexpected error updating widget: {e}")

        self.executor.submit(_update)

    def process_notifications(self, notifications: list) -> None:
        """Process and deduplicate notifications."""
        try:
            # Deduplicate notifications based on app and summary
            unique_notifications = []
            seen = set()
            
            for notif in notifications:
                key = f"{notif.get('app', '')}:{notif.get('summary', '')}"
                if key not in seen:
                    seen.add(key)
                    unique_notifications.append(notif)
            
            self.update_eww_widget(unique_notifications)
        except Exception as e:
            logger.error(f"Error processing notifications: {e}")

class NotificationHandler(FileSystemEventHandler):
    def __init__(self, manager: NotificationManager):
        self.manager = manager
        self.last_modified = 0
        self.retry_count = 0

    def on_modified(self, event):
        if event.src_path != str(NOTIF_PATH):
            return

        current_time = time.time()
        if current_time - self.last_modified < UPDATE_COOLDOWN:
            return

        self.last_modified = current_time
        self._handle_notification_update()

    def _handle_notification_update(self):
        """Handle notification file updates with retry logic."""
        for attempt in range(MAX_RETRIES):
            try:
                # Small delay to ensure file is completely written
                time.sleep(0.5)
                
                # Read and parse the notifications file
                with open(NOTIF_PATH, 'r') as f:
                    notifications = json.load(f)
                
                # Process notifications
                self.manager.process_notifications(notifications)
                self.retry_count = 0
                return
            except json.JSONDecodeError as e:
                logger.error(f"Failed to parse notifications file (attempt {attempt + 1}/{MAX_RETRIES}): {e}")
            except Exception as e:
                logger.error(f"Unexpected error (attempt {attempt + 1}/{MAX_RETRIES}): {e}")
            
            if attempt < MAX_RETRIES - 1:
                time.sleep(RETRY_DELAY)

def ensure_notification_file():
    """Ensure the notifications file exists and is valid JSON."""
    try:
        NOTIF_PATH.parent.mkdir(parents=True, exist_ok=True)
        if not NOTIF_PATH.exists():
            NOTIF_PATH.write_text('[]')
        else:
            # Validate existing file
            with open(NOTIF_PATH, 'r') as f:
                json.load(f)
    except Exception as e:
        logger.error(f"Error ensuring notification file: {e}")
        # Create fresh file if there's an error
        NOTIF_PATH.write_text('[]')

def main():
    try:
        # Ensure the notifications file exists and is valid
        ensure_notification_file()
        
        # Initialize notification manager
        manager = NotificationManager()
        
        # Set up file watcher
        event_handler = NotificationHandler(manager)
        observer = Observer()
        observer.schedule(event_handler, str(NOTIF_PATH.parent), recursive=False)
        
        logger.info("Starting notification watcher...")
        observer.start()
        
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            observer.stop()
            logger.info("Stopping notification watcher...")
        
        observer.join()
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        raise
    finally:
        if 'manager' in locals():
            manager.executor.shutdown(wait=True)

if __name__ == "__main__":
    main()