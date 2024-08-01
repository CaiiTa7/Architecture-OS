#!/bin/bash

# A script to resolve keyring and PGP issues on Arch Linux
# Ensure you run this script as root or with sudo

# URL for timezone service
TIMEZONE_URL="https://ipinfo.io/timezone"

# Keyserver URL
KEYSERVER_URL="hkps://keyserver.ubuntu.com"

# Function to handle errors
handle_error() {
    local message="$1"
    echo "$message"
    exit 1
}

# Function to get the system's current timezone using curl
get_timezone() {
    echo "Getting the current timezone..."
    timezone=$(curl -s "$TIMEZONE_URL")
    [ $? -ne 0 ] && handle_error "Failed to get timezone from $TIMEZONE_URL. Exiting..."
    [ -z "$timezone" ] && handle_error "Received empty timezone. Exiting..."
    echo "Current timezone is: $timezone"
}

# Function to sync system date and time using timedatectl
sync_date_and_time() {
    get_timezone
    echo "Setting system timezone and syncing date and time using timedatectl..."
    timedatectl set-timezone "$timezone"
    [ $? -ne 0 ] && handle_error "Failed to set timezone to $timezone. Exiting..."

    timedatectl set-ntp true
    [ $? -ne 0 ] && handle_error "Failed to enable NTP. Exiting..."

    echo "System date and time synced successfully."
}

# Function to refresh the keys
refresh_keys() {
    echo "Refreshing keys..."
    pacman-key --init
    pacman-key --populate archlinux
    [ $? -ne 0 ] && handle_error "Failed to refresh keys. Exiting..."
    echo "Keys refreshed successfully."
}

# Function to update the keyrings
update_keyrings() {
    echo "Updating keyrings..."
    pacman -Sy archlinux-keyring
    [ $? -ne 0 ] && handle_error "Failed to update keyrings. Exiting..."
    echo "Keyrings updated successfully."
}

# Function to import missing keys automatically
import_missing_keys() {
    echo "Checking for missing keys..."
    missing_keys=$(pacman -Sy --needed 2>&1 | grep 'unknown public key' | awk -F' ' '{print $NF}' | sed 's/://g')
    if [ -z "$missing_keys" ]; then
        echo "No missing keys found."
    else
        for key_id in $missing_keys; do
            echo "Importing missing key: $key_id..."
            gpg --keyserver "$KEYSERVER_URL" --recv-keys "$key_id"
            if [ $? -ne 0 ]; then
                echo "Failed to import key: $key_id. Removing problematic key..."
                pacman-key --delete "$key_id"
                [ $? -ne 0 ] && handle_error "Failed to delete key: $key_id. Exiting..."
                echo "Key $key_id removed successfully."
            else
                pacman-key --lsign-key "$key_id"
                if [ $? -ne 0 ]; then
                    echo "Failed to locally sign key: $key_id. Removing problematic key..."
                    pacman-key --delete "$key_id"
                    [ $? -ne 0 ] && handle_error "Failed to delete key: $key_id. Exiting..."
                    echo "Key $key_id removed successfully."
                else
                    echo "Key $key_id imported and signed successfully."
                fi
            fi
        done
    fi
}

# Function to handle PGP signature verification failure
handle_pgpsig_failure() {
    echo "Handling PGP signature verification failure..."
    pacman-key --refresh-keys
    [ $? -ne 0 ] && handle_error "Failed to refresh PGP keys. Exiting..."
    echo "PGP keys refreshed successfully."
}

# Main function to execute the script
main() {
    sync_date_and_time
    refresh_keys
    update_keyrings
    import_missing_keys
    handle_pgpsig_failure
    echo "All operations completed successfully."
}

# Run the main function
main
