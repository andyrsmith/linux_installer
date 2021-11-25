#!/bin/bash

pacman -Sy dialog

name=$(cat /tmp/user_name)

apps_path="/tmp/apps.csv"

curl https://raw.githubusercontent.com/andyrsmith/linux_installer/main/apps.csv > $apps_path

dialog --tile "Welcome!" \
    --msgbox "Welcome to the installation script for your apps and dotfiles!"\
    10 60

apps=("essential" "Essentials (Only Arch Install)" off
    "network" "Network" off
    "tools" "Nice tools to have (highly recommended)" on
    "tmux" "Tmux" on
    "notifier" "Notification tools" on
    "git" "Git & git tools" on
    "i3" "i3 wm" off
    "zsh" "The Z-Shell (zsh)" on
    "neovim" "Neovim" on
    "urxvt" "URxvt" on
    "firefox" "Firefox (browser)" on
    "js" "Javascript tooling" off
    "quitebrowser" "Quitebrowser (browser)" off
    "lynx" "Lynx (browser)" off
    "python" "Python" on
    "joplin" "Joplin" off)

dialog --checklist \
    "You can now choose what group of application you want to install. \n\n\
    You can select an option with SPACE and valid your choices with ENTER."\
    0 0 0 \
    "${apps[@]}" 2> app_choices

choices=$(cat app_choices) && rm app_choices
selection="^$(echo $choices | sed -e 's/ /,|^/g'),"
lines=$(grep -E "$selection" "$apps_path")
count=$(echo "$lines" | wc -l)
packages=$(echo "$lines" | awk -F {'print $2'})
echo "$selection" "$lines" "$count" >> "/tmp/packages"

pacman -Syu --noconfirm
rm -f /tmp/aur_queue

dialog --tile "Let's go!" --msgbox \
    "The system will now install everything you need.\n\n\
    It will take some time.\n\n " \
    13 60

c=0
echo "$packages" | while read -r line; do
c=$(("$c" + 1))
dialog --tile "Arch App installation" --infobox \
    "Downloading and installing program $c out of $count: $line..." \
    8 70

((pacman --noconfirm --needed -S "$line" > /tmp/arch_install 2>&2) \
    || echo "$line" >> /tmp/aur_queue) \
    || echo "$line" >> /tmp/arch_install_failed

if[ "$line" = "zsh" ]; then
    # Set Zsh as default terminal for our user
    chsh -s "$(which zsh)" "$name"
fi

if[ "$line" = "networkmanager" ]; then
    systemctl enable NetworkManger.service
fi
done
