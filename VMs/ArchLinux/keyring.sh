#!/bin/bash

# A script to resolve keyring and PGP issues on Arch Linux
# Ensure you run this script as root or with sudo

# Function to sync system date and time using timedatectl
sync_date_and_time() {
    echo "Setting system timezone and syncing date and time using timedatectl..."

    # Get current timezone
    timezone=$(timedatectl show -p Timezone --value)
    if [ -z "$timezone" ]; then
        echo "Failed to get current timezone. Exiting..."
        exit 1
    fi

    # Set the timezone
    timedatectl set-timezone "$timezone"
    if [ $? -ne 0 ]; then
        echo "Failed to set timezone to $timezone. Exiting..."
        exit 1
    fi
    echo "Timezone set to $timezone."

    # Enable NTP and sync time
    timedatectl set-ntp true
    if [ $? -ne 0 ]; then
        echo "Failed to enable NTP. Exiting..."
        exit 1
    fi
    echo "System date and time synced successfully."
}

# Function to update the keyrings
update_keyrings() {
    echo "Updating keyrings..."
    pacman -Sy archlinux-keyring
    if [ $? -ne 0 ]; then
        echo "Failed to update keyrings. Exiting..."
        exit 1
    fi
    echo "Keyrings updated successfully."
}

# Function to refresh the keys
refresh_keys() {
    echo "Refreshing keys..."
    pacman-key --init
    pacman-key --populate archlinux
    if [ $? -ne 0 ]; then
        echo "Failed to refresh keys. Exiting..."
        exit 1
    fi
    echo "Keys refreshed successfully."
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
            gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$key_id"
            if [ $? -ne 0 ]; then
                echo "Failed to import key: $key_id. Removing problematic key..."
                pacman-key --delete "$key_id"
                if [ $? -ne 0 ]; then
                    echo "Failed to delete key: $key_id. Exiting..."
                    exit 1
                fi
                echo "Key $key_id removed successfully."
            else
                pacman-key --lsign-key "$key_id"
                if [ $? -ne 0 ]; then
                    echo "Failed to locally sign key: $key_id. Removing problematic key..."
                    pacman-key --delete "$key_id"
                    if [ $? -ne 0 ]; then
                        echo "Failed to delete key: $key_id. Exiting..."
                        exit 1
                    fi
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
    if [ $? -ne 0 ]; then
        echo "Failed to refresh PGP keys. Exiting..."
        exit 1
    fi
    echo "PGP keys refreshed successfully."
}

# Main function to execute the script
main() {
    sync_date_and_time
    update_keyrings
    refresh_keys
    import_missing_keys
    handle_pgpsig_failure
    echo "All operations completed successfully."
}

# Run the main function
main
