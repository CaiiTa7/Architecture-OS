#!/bin/bash

# Configure the network
configure_network() {
    # Set the root password to Tigrou007
    echo "root:Tigrou007" | chpasswd
    
    echo "Configuration du réseau..."
    sed -i "127.0.0.1       archlinux" /etc/hosts
    pacman -Sy networkmanager
    systemctl enable NetworkManager
    systemctl start NetworkManager
    nmtui

}

#Function to activate NTP and synchronize the Europe/Brussels system clock
enable_ntp() {
    echo "Activation du ntp et synchronisation de l'horloge du système..."

    touch /etc/localtime
    ls -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
    echo "fr_BE.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    timedatectl set-ntp true
    timedatectl set-timezone Europe/Brussels

}

# Configure the system language and locale
configure_language() {
    echo "Configuration de la langue et du locale du système..."

    echo "LANG=fr_BE.UTF-8" > /etc/locale.conf
    export LANG=fr_BE.UTF-8
    echo "KEYMAP=be-latin1" > /etc/vconsole.conf

}

# Configure the hostname
configure_hostname() {
    echo "Configuration du hostname..."

    echo "archlinux" > /etc/hostname 
}

# Configure the initramfs
configure_initramfs() {
    echo "Configuration de l'initramfs..." 

    mkinitcpio -p linux # -p to ignore kernel warning linux to use linux kernel
}

# Configure the bootloader (GRUB)
configure_bootloader() {
    echo "Configuration du bootloader..."

    pacman -Sy grub efibootmgr os-prober mtools # Install grub and os-prober to detect other OS
    grub-install /dev/sda # Install grub on the disk
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

    useradd -m -G users,wheel -s /bin/zsh student # -m to create home directory, -G to add to groups users and wheel (sudo) and -s to set shell to zsh shell without password
    echo "student:Tigrou007" | chpasswd
    echo "student ALL=(ALL) ALL" > /etc/sudoers # Allow student to use sudo
}

# Main function
main() {
    configure_network
    enable_ntp
    configure_language
    configure_hostname
    configure_initramfs
    configure_bootloader
    install_packages
    configure_user
    exit
}

main
