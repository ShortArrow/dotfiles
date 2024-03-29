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
  zsh \
  neofetch \
  tmux \
  bat \
  fzf \
  exa \
  zellij

# Install Languages
RUN pacman --noconfirm -S \
  zig \
  nodejs \
  npm \
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
  diff-so-fancy \
  ripgrep \
  fd \
  github-cli

# Make User
ARG USERNAME='who'
RUN useradd -m -G wheel -s /bin/bash $USERNAME
ENV HOME /home/$USERNAME
WORKDIR /home/$USERNAME
USER $USERNAME

# Add cargo
RUN rustup install stable
ENV PATH "`yarn global bin`:$PATH"
ENV RUSTUP_HOME "/home/$USERNAME/.rustup"

# Install Rust Tools
RUN cargo install \
  git-graph \
  vivid \
  lsd

# Install Yarn Tools
ENV PATH "/home/$USERNAME/.yarn/bin:$PATH"
RUN yarn global add neovim

# Clone Repo
RUN /bin/mkdir -p /home/$USERNAME/Documents/GitHub/dotfiles
WORKDIR /home/$USERNAME/Documents/GitHub/dotfiles
COPY . .

# Link Bash config
RUN ln -s "/home/$USERNAME/Documents/GitHub/dotfiles/bash/src" ~/.bash_myplug
USER root
RUN ln -s "/home/$USERNAME/Documents/GitHub/dotfiles/bash/src" /usr/local/bin/.bash_myplug
RUN chsh -s /bin/bash $USERNAME
USER $USERNAME
RUN bash \
  && echo 'source ~/.bash_myplug/bash_myplug.sh' >> ~/.bashrc

# Link Neovim config
RUN rm -rf ~/.config/nvim \
  && mkdir -p ~/.config \
  && ln -s $HOME/Documents/GitHub/dotfiles/nvim ~/.config/nvim \
  && file ~/.config/nvim

RUN git config --global --add safe.directory /home/who/Documents/GitHub/dotfiles

ENTRYPOINT ["/bin/bash", "-l"]
