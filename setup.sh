#!/bin/bash

user="hkm"

root_check() 
{
    if [[ $UID -ne 0 ]]; then
        echo "Run as root. Exiting." >&2
        exit 1
    fi
}

root_check

# install neccessary packages
dnf update && dnf -y upgrade
dnf install -y vim tmux git gcc

# Set user
useradd -m "$user"
usermod "$user" -aG wheel
passwd "$user"
passwd root

# Install tor
dnf install -y epel-release
cat ./Tor.repo > /etc/yum.repos.d/Tor.repo
dnf install -y tor

# Enable neccessary services
systemctl enable --now tor
systemctl enable --now crond

# Set local dirs & dotfiles
su "$user" -c "mkdir -p ~/.local/bin ~/.local/src ~/.local/share"
su "$user" -c "git clone https://github.com/Hmz-x/dotfiles ~/.local/dotfiles"
"/home/$user/.local/dotfiles/dotfiles-install.sh" "$user"
cp ./target.env /etc/profile.d/
. /etc/profile.d/target.env

# Set vim plugins as the non-root user
su "$user" -c "git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim"
su "$user" -c "vim +PluginInstall +qall"

# Install proxychains
su "$user" -c "git clone https://github.com/rofl0r/proxychains-ng.git ~/.local/src/proxychains-ng"
su "$user" -c "cd ~/.local/src/proxychains-ng && ./configure --prefix=/usr --sysconfdir=/etc && make"
make -C ~/.local/src/proxychains-ng install
make -C ~/.local/src/proxychains-ng install-config
# Add tor proxy configuration
echo "socks5 127.0.0.1 9050" >> /etc/proxychains.conf

# Install DoS tools as the non-root user
su "$user" -c "git clone https://github.com/gkbrk/slowloris ~/.local/bin/slowloris"
chmod 755 "/home/$user/.local/bin/slowloris/slowloris.py"
ln -sf "/home/$user/.local/bin/slowloris/slowloris.py" /usr/local/bin/slowloris.py

su "$user" -c "git clone https://github.com/jseidl/GoldenEye ~/.local/bin/goldeneye"
chmod 755 "/home/$user/.local/bin/goldeneye/goldeneye.py"
ln -sf "/home/$user/.local/bin/goldeneye/goldeneye.py" /usr/local/bin/goldeneye.py

su "$user" -c "git clone https://github.com/niedong/saphyra ~/.local/bin/saphyra"
chmod 755 "/home/$user/.local/bin/saphyra/saphyra.py"
ln -sf "/home/$user/.local/bin/saphyra/saphyra.py" /usr/local/bin/saphyra.py

su "$user" -c "git clone https://github.com/isdrupter/xerxes ~/.local/bin/xerxes"
gcc "/home/$user/.local/bin/xerxes/xerxes.c" -o /usr/local/bin/xerxes

# Compile http_req_overload as non-root user
su "$user" -c "make -f ~/.local/dotfiles/misc/http_req_overload.c"
ln -sf "/home/$user/.local/dotfiles/misc/http_req_overload" /usr/local/bin/http_req_overload

# install crontab
su "$user" -c "crontab ./dos.crontab"
