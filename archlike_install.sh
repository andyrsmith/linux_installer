#!/bin/bash
pacman --noconfirm -S dialog

name=$(whoami)

echo "$name" > /tmp/user_name

dialog --tile "App and Dotfiles installation" --yesno \
    "Do you want to install all your apps and your dotfiles?" \
    10 60 \
    && curl https://raw.githubusercontent.com/andyrsmith/linux_install/install_arch_apps.sh > /tmp/install_apps.sh \
    && sudo -u $name bash /tmp/install_apps.sh
