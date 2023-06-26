FROM archlinux:latest
SHELL ["/bin/bash", "-l", "-c"]

RUN pacman --noconfirm -Syu

# Install General Purpose Tools
RUN pacman --noconfirm -S \
  git \
  neovim \
  wget \
  unzip \
  sudo \
  starship \
  zsh

# Install Languages
RUN pacman --noconfirm -S \
  zig \
  nodejs \
  python \
  go \
  rustup \
  deno \
  luarocks \
  python-pip
RUN corepack enable

# Install Tools
RUN pacman --noconfirm -S \
  lazygit \
  git-delta \
  ripgrep \
  fd \
  github-cli

# Make User
ARG USERNAME='who'
RUN useradd -m -G wheel -s /bin/bash $USERNAME
ENV HOME /home/$USERNAME
WORKDIR /home/$USERNAME
USER $USERNAME
ENV PATH "/home/$USERNAME/.cargo/bin"

# Add cargo
RUN rustup install stable
ENV PATH "/home/$USERNAME/.cargo/bin:${PATH}"
ENV RUSTUP_HOME "/home/$USERNAME/.rustup"

# Install Rust Tools
RUN cargo install \
  git-graph \
  vivid \
  lsd

# Clone Repo
RUN /bin/mkdir -p /home/$USERNAME/Documents/GitHub/dotfiles
WORKDIR /home/$USERNAME/Documents/GitHub/dotfiles
COPY . .


# Link Bash config
USER root
RUN ln -s "/home/$USERNAME/Documents/GitHub/dotfiles/bash/src" ~/.bash_myplug
RUN ln -s "/home/$USERNAME/Documents/GitHub/dotfiles/bash/src" /usr/local/bin/.bash_myplug
USER $USERNAME
RUN bash \
  && echo 'source ~/.bash_myplug/bash_myplug.sh' >> ~/.bashrc

# Link Neovim config
RUN rm -rf ~/.config/nvim \
  && mkdir -p ~/.config \
  && ln -s $HOME/Documents/GitHub/dotfiles/nvim ~/.config/nvim \
  && file ~/.config/nvim

ENTRYPOINT ["/bin/bash", "-l"]
