#!/bin/bash

# Folders and Files
LOG_DIR="./logs"                               # Log directory
LOG_FILE="$LOG_DIR/fortigate_cleanup.log"      # Log file path
INPUT_FILE="ips_list.txt"                     # Input file

# FortiGate Connection Variables
PYTHON_CMD="python3 forti.py"
FORTI_HOST="123.123.123.123"
FORTI_USER="apitoken"
FORTI_PASSWORD="xxx"
FORTI_DIRECTION="Inbound"
FORTI_GROUP="BlockIP"

# Test mode flag (set to 1 for true, 0 for false)
TEST_MODE=0

# Create log directory if it doesn't exist and should not recreate it each time
setup_logging() {
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR"
        echo "Created log directory: $LOG_DIR"
    fi
}

# Record a log message with a timestamp and log level
write_log() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    level=$1
    message=$2
    echo "$timestamp [$level] - $message" | tee -a "$LOG_FILE"
}

# Validate IP address format using regex
validate_ip_address() {
    local ip=$1
    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        if [[ ${octets[0]} -ge 0 && ${octets[0]} -le 255 && 
              ${octets[1]} -ge 0 && ${octets[1]} -le 255 && 
              ${octets[2]} -ge 0 && ${octets[2]} -le 255 && 
              ${octets[3]} -ge 0 && ${octets[3]} -le 255 ]]; then
            return 0  # valid IP
        fi
    fi
    return 1  # invalid IP
}

# Get IP address from a line containing "Block-{IP}"
get_ip_address() {
    echo "$1" | grep -oP '(?<=Block-)[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' || echo ""
}

# exit with cleanup
cleanup() {
    write_log "INFO" "Script terminated. Exiting."
    exit 0
}

# --- Main Script ---
# Setup logging directory
setup_logging

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    write_log "ERROR" "Cannot find input file: $INPUT_FILE"
    cleanup
fi

write_log "INFO" "Starting IP cleanup script"

# Process each line in the input file
while read -r line; do
    write_log "INFO" "Reading entry: $line"
    
    # Get IP address from the line
    ip_address=$(get_ip_address "$line")
    
    # Skip if no IP found
    if [ -z "$ip_address" ]; then
        write_log "WARNING" "Skipping: No IP found in '$line'"
        continue
    fi
    
    # Validate IP address format
    if ! validate_ip_address "$ip_address"; then
        write_log "ERROR" "Invalid IP format: $ip_address. Skipping."
        continue
    fi

    # If in test mode, just print the action and skip actual command
    if [ $TEST_MODE -eq 1 ]; then
        write_log "INFO" "TEST MODE: Would release IP $ip_address (no action taken)"
        continue
    fi
    
    # Build and run the release command
    release_command="$PYTHON_CMD --user $FORTI_USER --pwd $FORTI_PASSWORD \
        --host $FORTI_HOST --direction $FORTI_DIRECTION \
        --in_group $FORTI_GROUP --targetip $ip_address --action release"
    
    write_log "INFO" "Attempting to release IP: $ip_address"
    
    # Execute the command and check result
    if $release_command >> "$LOG_FILE" 2>&1; then
        write_log "INFO" "Success: Released IP $ip_address"
    else
        write_log "ERROR" "Failed: Could not release IP $ip_address"
        cleanup
    fi
done < "$INPUT_FILE"

write_log "INFO" "Cleanup completed"
cleanup
