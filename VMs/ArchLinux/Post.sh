#!/bin/bash

# function to set up user student
add_user() {
    # Création de l'utilisateur student
    useradd -m -G wheel -s /bin/zsh student
    echo "student:Tigrou007" | chpasswd
    # Installation de sudo
    pacman -S sudo --noconfirm
    # Décommenter la ligne permettant aux membres du groupe wheel d'utiliser sudo
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

}