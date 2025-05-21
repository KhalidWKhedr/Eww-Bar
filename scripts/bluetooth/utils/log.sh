#!/bin/bash

# Log levels
LOG_LEVEL_ERROR="ERROR"
LOG_LEVEL_WARN="WARN"
LOG_LEVEL_INFO="INFO"

# Log function
log() {
    local message="$1"
    local level="${2:-$LOG_LEVEL_INFO}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Color codes
    local RED='\033[0;31m'
    local YELLOW='\033[1;33m'
    local GREEN='\033[0;32m'
    local NC='\033[0m' # No Color
    
    # Set color based on log level
    case "$level" in
        "$LOG_LEVEL_ERROR")
            color="$RED"
            ;;
        "$LOG_LEVEL_WARN")
            color="$YELLOW"
            ;;
        *)
            color="$GREEN"
            ;;
    esac
    
    # Print the log message with color
    echo -e "${color}[$timestamp] [$level] $message${NC}"
} 