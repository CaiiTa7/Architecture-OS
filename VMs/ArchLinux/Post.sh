#!/bin/bash

# function to set up user student
add_user() {
    # Creating the student user
    useradd -m -G wheel student
    echo "student:Tigrou007" | chpasswd

    # Uncomment the line allowing members of the wheel group to use sudo
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

}

# function to call all the other functions
main() {
    add_user
}

main
