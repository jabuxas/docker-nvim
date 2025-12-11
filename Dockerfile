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
        alacritty tmux \
        && pacman -Scc --noconfirm \
        && rm -rf /var/cache/pacman/pkg/*

RUN     curl -LsSf https://astral.sh/uv/install.sh | sh \
        && mv /root/.local/bin/uv /usr/local/bin/uv \
        && mv /root/.local/bin/uvx /usr/local/bin/uvx

RUN     mkdir -p /tmp/fonts \
        && mkdir -p /usr/share/fonts/terminess-nerd-font \
        && cd /tmp/fonts \
        && curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip \
        && unzip Terminus.zip -d /usr/share/fonts/terminess-nerd-font \
        && fc-cache -fv \
        && rm -rf /tmp/fonts

WORKDIR /root

RUN     git clone --depth 1 https://github.com/jabuxas/dotfiles /tmp/dotfiles \
        && mkdir -p /root/.config \
        && cp -r /tmp/dotfiles/dot_config/nvim /root/.config/nvim \
        && cp -r /tmp/dotfiles/dot_config/alacritty /root/.config/alacritty \
        && cp /tmp/dotfiles/dot_config/tmux/tmux.conf /root/.tmux.conf \
        && rm -rf /tmp/dotfiles

RUN     echo "alias v=nvim" >> /root/.bashrc \
        && mkdir -p /root/.config/fish \
        && echo "alias v=nvim" >> /root/.config/fish/config.fish

RUN     nvim --headless "+Lazy! sync" +qa || true

CMD     ["alacritty", "-e", "tmux"]
