#!/bin/bash
set -e

# Function to create partitions and format them
format_partitions() {
    echo "Formatage des partitions..."
    pacman -Syy # Update pacman database
    pacman -S parted --noconfirm 
    # Le nom du disque à partitionner
    disk="/dev/sda"

    # Créer une nouvelle table de partitions de type gpt
    echo -e "g\nw" | fdisk $disk

    # Créer la partition de boot de 512M
    echo -e "n\n\n\n+512M\nw" | fdisk $disk

    # Créer la partition de swap de 4G
    echo -e "n\n\n\n+4G\nt\n\n82\nw" | fdisk $disk

    # Créer la partition racine avec le reste de l'espace disque
    echo -e "n\n\n\n\nw" | fdisk $disk

    # Formater la partition de boot en ext2
    mkfs.ext2 ${disk}1

    # Formater la partition de swap
    mkswap ${disk}2
    swapon ${disk}2

    # Formater la partition racine en ext4
    mkfs.ext4 ${disk}3

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