#!/bin/bash
set -e

# Function to create partitions and format them
format_partitions() {
    echo "Formatage des partitions..."
fdisk /dev/sda << FDISK_CMDS
o
n
1

+512M
n
2

+4G
n
3


w
FDISK_CMDS

}

# Function to mount partitions, enable swapon, sda1 is boot, sda2 is swap, sda3 is root
mount_partitions() {
    echo "Montage des partitions..."

    pacman -Syy # Update pacman database
    mount /dev/sda3 /mnt
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot
    
}

# Function to install Arch Linux
install_arch() {
    echo "Installation d'Arch Linux..."
    timedatectl set-timezone Europe/Brussels
    timedatectl set-ntp true
    pacstrap -i /mnt base linux linux-firmware nano # -i = ignore missing packages
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

# Executing functions in order
format_partitions
mount_partitions
install_arch
generate_fstab
chroot_environment