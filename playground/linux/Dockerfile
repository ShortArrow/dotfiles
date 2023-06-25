FROM archlinux:latest

RUN pacman --noconfirm -Syu

# Install General Purpose Tools
RUN pacman --noconfirm -S \
  git \
  neovim \
  wget \
  unzip \
  sudo

# Install Languages
RUN pacman --noconfirm -S \
  zig \
  nodejs \
  python \
  go \
  rustup \
  deno \
  luarocks \
  cargo

ARG USERNAME='who'
RUN useradd -m -G wheel -s /bin/bash $USERNAME
ENV HOME /home/$USERNAME
WORKDIR /home/$USERNAME
USER $USERNAME
RUN mkdir -p ./Documents/GitHub/dotfiles
WORKDIR /home/$USERNAME/Documents/GitHub/dotfiles
COPY . .

# Link Bash config
USER root
RUN bash -c "cd /home/$USERNAME/Documents/GitHub/dotfiles/bash && ./setup.sh $USERNAME" \
  && ln -s "/home/$USERNAME/Documents/GitHub/dotfiles/bash/src" ~/.bash_myplug
USER $USERNAME
RUN bash \
  && file ~/.bash_myplug \
  && echo 'source ~/.bash_myplug/bash_myplug.sh' >> ~/.bashrc

# Link Neovim config
RUN rm -rf ~/.config/nvim \
  && mkdir -p ~/.config \
  && ln -s $HOME/Documents/GitHub/dotfiles/nvim ~/.config/nvim \
  && file ~/.config/nvim
CMD /bin/bash
