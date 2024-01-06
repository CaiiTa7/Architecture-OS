#!/bin/bash
set -e

# Function to create partitions
create_partitions() {
    echo "Création des partitions sur /dev/sda..."

    # Delete all existing partitions
    sfdisk --delete /dev/sda 2> /dev/null || true # Ignore errors if partitions don't exist and nullify output

    # Create new partitions (512M boot, 4G swap, rest root)
    sfdisk /dev/sda <<EOF
,512M,*
,4G
,
EOF

    # Update partition table
    partprobe /dev/sda

}

# Function to format partitions
format_partitions() {
    echo "Formatage des partitions..."

    mkfs.ext2 /dev/sda1
    mkswap /dev/sda2
    swapon /dev/sda2
    mkfs.ext4 /dev/sda3
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

    pacstrap -K /mnt base linux linux-firmware nano curl # -K to ignore kernel warning
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
create_partitions
format_partitions
mount_partitions
install_arch
generate_fstab
chroot_environment
