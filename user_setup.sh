#!/bin/bash

user="hkm"

non_root_check() 
{
    if [[ $UID -eq 0 ]]; then
        echo "Do not run as root. Exiting." >&2
        exit 1
    fi
}

non_root_check

# Set local dirs & dotfiles
mkdir -p ~/.local/bin ~/.local/src ~/.local/share
git clone https://github.com/Hmz-x/dotfiles ~/.local/dotfiles
~/.local/dotfiles/dotfiles-install.sh "$user"

# Set vim plugins
git clone https://github.com/VundleVim/Vundle.vim.git "/home/${user}/.vim/bundle/Vundle.vim"
vim +PluginInstall +qall

# Install proxychains
git clone https://github.com/rofl0r/proxychains-ng.git ~/.local/src/proxychains-ng
cd proxychains-ng && ./configure --prefix=/usr --sysconfdir=/etc && 
  make && su root -c "make install" && su root -c "make install-config"

# add tor proxy configuration
su root -c 'echo "socks5 127.0.0.1 9050" > /etc/proxychains.conf'

# install DoS tools
git clone https://github.com/gkbrk/slowloris ~/.local/bin/slowloris
su root -c "ln -s ~/.local/bin/slowloris/slowloris.py /usr/local/bin/slowloris.py"
git clone https://github.com/jseidl/GoldenEye ~/.local/bin/goldeneye
su root -c "ln -s ~/.local/bin/goldeneye/goldeneye.py /usr/local/bin/goldeneye.py"
git clone https://github.com/niedong/saphyra ~/.local/bin/saphyra
su root -c "ln -s ~/.local/bin/saphyra/saphyra.py /usr/local/bin/saphyra.py"
make -f ~/.local/dotfiles/misc/http_req_overload.c
su root -c "ln -s ~/.local/dotfiles/misc/http_req_overload /usr/local/bin/http_req_overload"
