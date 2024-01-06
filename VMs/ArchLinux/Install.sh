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

    pacstrap -K /mnt base linux linux-firmware nano  # -K to ignore kernel warning
}

# Function to generate fstab
generate_fstab() {
    echo "Génération de fstab..."
    
    genfstab -U /mnt >> /mnt/etc/fstab
}

# Function for chroot in the new environment
chroot_environment() {
    echo "Chroot dans le nouvel environnement..."
# Mount the necessary filesystems in the chroot    
    mount --bind /proc /mnt/proc
    mount --bind /sys /mnt/sys
    mount --bind /dev /mnt/dev
    mount --bind /run /mnt/run

    # Passez dans le chroot
    arch-chroot /mnt /bin/bash
    echo "root:Tigrou007" | chpasswd

    # Mount mount points recursively in the chroot
    mount -t proc proc /proc
    mount -t sysfs sys /sys
    mount -t devtmpfs udev /dev
    mount -t devpts devpts /dev/pts

}

# Configure the network
configure_network() {
    echo "Configuration du réseau..."

    pacman -Sy networkmanager
    systemctl enable NetworkManager
    systemctl start NetworkManager
    nmtui
  
}

#Function to activate NTP and synchronize the Europe/Brussels system clock
enable_ntp() {
    echo "Activation du ntp et synchronisation de l'horloge du système..."

    timedatectl set-ntp true
    timedatectl set-timezone Europe/Brussels
    touch /etc/localtime
    ls -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
    hwclock --systohc # Synchronise hardware clock from system clock

}

# Configure the system language and locale
configure_language() {
    echo "Configuration de la langue et du locale du système..."

    echo "LANG=fr_BE.UTF-8" > /etc/locale.conf
    echo "KEYMAP=be-latin1" > /etc/vconsole.conf
    echo "fr_BE.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
}

# Configure the hostname
configure_hostname() {
    echo "Configuration du hostname..."

    echo "archlinux" >> /etc/hostname 
}

# Configure the initramfs
configure_initramfs() {
    echo "Configuration de l'initramfs..." 

    mkinitcpio -p linux # -p to ignore kernel warning linux to use linux kernel
}

# Configure the bootloader (GRUB)
configure_bootloader() {
    echo "Configuration du bootloader..."

    pacman -Sy grub
    grub-install /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
}

# Installation of packages python python3 neofetch zsh
install_packages() {
    echo "Installation des packages python python3 neofetch..."

    pacman -Sy python python3 neofetch zsh
}

# Configure the user student with password Tigrou007
configure_user() {
    echo "Configuration de l'utilisateur student..."

    useradd -m -aG users,wheel -s /bin/zsh student # -m to create home directory, -aG to add to groups users and wheel (sudo) and -s to set shell to zsh shell without password
    echo "student:Tigrou007" | chpasswd
    echo "student ALL=(ALL) ALL" > /etc/sudoers # Allow student to use sudo
}

# Function sot exit and reoot properly
exit_and_reboot() {
    echo "Sortie et redémarrage..."

    exit
    umount -R /mnt
    reboot
}

# Executing functions in order

#create_partitions
format_partitions
mount_partitions
install_arch
generate_fstab
chroot_environment
configure_network
enable_ntp
configure_language
configure_hostname
configure_initramfs
configure_bootloader
install_packages
configure_user
exit_and_reboot

echo "Terminé! Assurez-vous de vérifier les configurations avant de redémarrer."