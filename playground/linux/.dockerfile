FROM archlinux:latest

RUN pacman --noconfirm -Syuu 
RUN pacman --noconfirm -S git
RUN pacman --noconfirm -S neovim

ARG USERNAME='who'
RUN useradd -m -G wheel -s /bin/bash $USERNAME
ENV HOME /home/$USERNAME
WORKDIR /home/$USERNAME
USER $USERNAME
RUN mkdir -p ./Documents/GitHub

WORKDIR /home/$USERNAME/Documents/GitHub
RUN git clone https://github.com/ShortArrow/dotfiles.git

WORKDIR /home/$USERNAME/Documents/GitHub/dotfiles

# Link Bash config
RUN bash ./bash/setup.sh
RUN echo 'source ~/.bash_myplug' >> ~/.bashrc

# Link Neovim config
RUN rm -rf ~/.config/nvim
RUN mkdir -p ~/.config
RUN ln -s $HOME/Documents/GitHub/dotfiles/nvim ~/.config/nvim # caution! Don't needs slash at last.
RUN ls ~/.config/nvim # check link

# Install Packer
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
