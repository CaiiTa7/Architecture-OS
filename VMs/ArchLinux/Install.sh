#!/bin/bash
set -e

# Function to change the keyboard layout to belgian
change_keyboard() {
    echo "Changement du clavier..."
    loadkeys be-latin1
}

#Function to activate NTP and synchronize the Europe/Brussels system clock
enable_ntp() {
    echo "Activation du ntp et synchronisation de l'horloge du système..."
    timedatectl set-ntp true
    timedatectl set-timezone Europe/Brussels
}

# Function to display partition information
print_partition_info() {
    echo "Informations sur les partitions :"
    fdisk -l /dev/sda
}

# Function to create partitions
create_partitions() {
    echo "Création des partitions sur /dev/sda..."

    # Supprimer toutes les partitions existantes
    sfdisk --delete /dev/sda 2> /dev/null || true

    # Créer la partition de boot (512M)
    sfdisk /dev/sda <<EOF
,512M,*
,4G
,
EOF

    # Update partition table
    partprobe /dev/sda

    print_partition_info
}

# Function to format partitions
format_partitions() {
    echo "Formatage des partitions..."

    mkfs.ext2 /dev/sda1
    mkswap /dev/sda2
    mkfs.ext4 /dev/sda3
}

# Function to mount partitions
mount_partitions() {
    echo "Montage des partitions..."

    mount /dev/sda3 /mnt
    mkdir /mnt/boot
    mount /dev/sda1 /mnt/boot
    swapon /dev/sda2
}

# Function to install Arch Linux
install_arch() {
    echo "Installation d'Arch Linux..."

    pacstrap -i /mnt base linux linux-firmware neovim
}

# Function to generate fstab
generate_fstab() {
    echo "Génération de fstab..."
    
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Function for chroot in the new environment
chroot_environment() {
    echo "Chroot dans le nouvel environnement..."
    
    arch-chroot /mnt <<ENDCHROOT
    # Configuration du mot de passe root avec chpasswd
    echo "root:Tigrou007" | chpasswd -e
ENDCHROOT

# Exécution des fonctions dans l'ordre
change_keyboard
enable_ntp
create_partitions
format_partitions
mount_partitions
install_arch
generate_fstab
chroot_environment

echo "Terminé! Assurez-vous de vérifier les configurations avant de redémarrer."

