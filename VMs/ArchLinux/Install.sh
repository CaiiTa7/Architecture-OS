#!/bin/bash
set -e

# Function to create partitions, format and mount them
disk_configuration() {

    echo "Formatage des partitions..."

fdisk /dev/sda << FDISK_CMDS
g 
n 
1

+512M
t 
1
4 
n 
2 

+4G 
t 
2 
19 
n  
3 


t
3
24
w
FDISK_CMDS

        # Format partitions
        mkfs.ext2 /dev/sda1 # Boot
        mkfs.ext4 /dev/sda3 # Root
        mkswap /dev/sda2 # Swap
        swapon /dev/sda2

        # Mount partitions
        mount /dev/sda3 /mnt
        mkdir /mnt/boot
        mount /dev/sda1 /mnt/boot
}

# Function to install Arch Linux
install_arch() {
    echo "Installation d'Arch Linux..."
    timedatectl set-ntp true # Synchronise time
    timedatectl set-timezone Europe/Brussels # Set timezone
    pacstrap -K /mnt base linux linux-firmware
}

# Function to generate fstab
generate_fstab() {
    echo "Génération de fstab..."
    
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Function for chroot in the new environment
chroot_environment() {
    echo "Chroot dans le nouvel environnement..."
    curl -LJ https://raw.githubusercontent.com/CaiiTa7/Architecture-OS/main/VMs/ArchLinux/Chroot.sh -o /mnt/Chroot.sh
    chmod +x /mnt/Chroot.sh
    # Go to the chroot
    arch-chroot /mnt

}

# function main
main() {
    disk_configuration
    install_arch
    generate_fstab
    chroot_environment
}

# Call main function
main