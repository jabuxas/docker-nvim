FROM    archlinux:latest

RUN     pacman-key --init \
        && pacman-key --populate archlinux \
        && pacman -Syu --noconfirm \
        && pacman -S --noconfirm \
        neovim \
        base-devel git sudo curl wget unzip ripgrep fd \
        fontconfig \
        go gopls rust rust-analyzer jdk-openjdk python python-pip lua luarocks \
        nodejs npm \
        bash fish \
        lazygit \
        && pacman -Scc --noconfirm \
        && rm -rf /var/cache/pacman/pkg/*

RUN     curl -LsSf https://astral.sh/uv/install.sh | sh \
        && mv /root/.local/bin/uv /usr/local/bin/uv \
        && mv /root/.local/bin/uvx /usr/local/bin/uvx

RUN     mkdir -p /tmp/fonts \
        && cd /tmp/fonts \
        && curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip \
        && unzip Terminus.zip -d /usr/share/fonts/terminess-nerd-font \
        && fc-cache -fv \
        && rm -rf /tmp/fonts

WORKDIR /root

# Clone nvim config from dotfiles
RUN     git clone --depth 1 https://github.com/jabuxas/dotfiles /tmp/dotfiles \
        && mkdir -p /root/.config \
        && cp -r /tmp/dotfiles/dot_config/nvim /root/.config/nvim \
        && rm -rf /tmp/dotfiles

# Run nvim headless to install plugins (lazy.nvim)
RUN     nvim --headless "+Lazy! sync" +qa || true

CMD     ["nvim"]
