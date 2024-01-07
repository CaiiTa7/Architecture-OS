#!/bin/bash

# Function for timezone, locale, keyboard and hostname
locale_timezone_keyboard_hostname() {

    # Configure timezone, locale, keyboard and hostname
    ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
    hwclock --systohc
    sed -i 's/#fr_BE.UTF-8 UTF-8/fr_BE.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=fr_BE.UTF-8" >> /etc/locale.conf
    echo "KEYMAP=be-latin1" >> /etc/vconsole.conf
    echo "archlinux" >> /etc/hostname
}

# Function to install packages
install_packages() {
    pacman -S zsh neofetch python python3 networkmanager wget sudo --noconfirm
    systemctl enable NetworkManager
}

# Fuction for initramfs
initramfs() {
    mkinitcpio -P
}

# Function for root password
root_password() {
    echo "root:Tigrou007" | chpasswd
}

# Function for grub
grub() {
    pacman -S grub dosfstools --noconfirm
    grub-install --target=i386-pc /dev/sda
    grub-mkconfig -o /boot/grub/grub.cfg
}

# Function main
main() {
    locale_timezone_keyboard_hostname
    initramfs
    grub
    root_password
    install_packages
}

# Call main function
main