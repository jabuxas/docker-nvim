FROM    archlinux:latest

# 1. Install Base System + Kitty + Dependencies
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
        kitty \
        tmux \
        && pacman -Scc --noconfirm \
        && rm -rf /var/cache/pacman/pkg/*

# 2. Install uv (Python tools)
RUN     curl -LsSf https://astral.sh/uv/install.sh | sh \
        && mv /root/.local/bin/uv /usr/local/bin/uv \
        && mv /root/.local/bin/uvx /usr/local/bin/uvx

# 3. Install Terminess Nerd Font
RUN     mkdir -p /tmp/fonts \
        && mkdir -p /usr/share/fonts/terminess-nerd-font \
        && cd /tmp/fonts \
        && curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/Terminus.zip \
        && unzip Terminus.zip -d /usr/share/fonts/terminess-nerd-font \
        && fc-cache -fv \
        && rm -rf /tmp/fonts

WORKDIR /root

# 4. Clone Dotfiles (Only taking nvim/tmux to avoid terminal config conflicts)
RUN     git clone --depth 1 https://github.com/jabuxas/dotfiles /tmp/dotfiles \
        && mkdir -p /root/.config \
        && cp -r /tmp/dotfiles/dot_config/nvim /root/.config/nvim \
        && cp /tmp/dotfiles/dot_config/tmux/tmux.conf /root/.tmux.conf \
        && rm -rf /tmp/dotfiles

# 5. Shell Aliases
RUN     echo "alias v=nvim" >> /root/.bashrc \
        && echo "[[ -f ~/.bashrc ]] && . ~/.bashrc" >> /root/.bash_profile \
        && mkdir -p /root/.config/fish \
        && echo "alias v=nvim" >> /root/.config/fish/config.fish

# 6. Configure Kitty (Hardcoded Nord Theme + Font)
RUN     mkdir -p /root/.config/kitty \
        && echo "# Fonts" > /root/.config/kitty/kitty.conf \
        && echo "font_family      Terminess Nerd Font" >> /root/.config/kitty/kitty.conf \
        && echo "bold_font        auto" >> /root/.config/kitty/kitty.conf \
        && echo "italic_font      auto" >> /root/.config/kitty/kitty.conf \
        && echo "bold_italic_font auto" >> /root/.config/kitty/kitty.conf \
        && echo "font_size 12.0" >> /root/.config/kitty/kitty.conf \
        && echo "" >> /root/.config/kitty/kitty.conf \
        && echo "# Nord Theme" >> /root/.config/kitty/kitty.conf \
        && echo "foreground            #D8DEE9" >> /root/.config/kitty/kitty.conf \
        && echo "background            #2E3440" >> /root/.config/kitty/kitty.conf \
        && echo "selection_foreground  #000000" >> /root/.config/kitty/kitty.conf \
        && echo "selection_background  #FFFACD" >> /root/.config/kitty/kitty.conf \
        && echo "url_color             #0087BD" >> /root/.config/kitty/kitty.conf \
        && echo "cursor                #81A1C1" >> /root/.config/kitty/kitty.conf \
        && echo "color0  #3B4252" >> /root/.config/kitty/kitty.conf \
        && echo "color8  #4C566A" >> /root/.config/kitty/kitty.conf \
        && echo "color1  #BF616A" >> /root/.config/kitty/kitty.conf \
        && echo "color9  #BF616A" >> /root/.config/kitty/kitty.conf \
        && echo "color2  #A3BE8C" >> /root/.config/kitty/kitty.conf \
        && echo "color10 #A3BE8C" >> /root/.config/kitty/kitty.conf \
        && echo "color3  #EBCB8B" >> /root/.config/kitty/kitty.conf \
        && echo "color11 #EBCB8B" >> /root/.config/kitty/kitty.conf \
        && echo "color4  #81A1C1" >> /root/.config/kitty/kitty.conf \
        && echo "color12 #81A1C1" >> /root/.config/kitty/kitty.conf \
        && echo "color5  #B48EAD" >> /root/.config/kitty/kitty.conf \
        && echo "color13 #B48EAD" >> /root/.config/kitty/kitty.conf \
        && echo "color6  #88C0D0" >> /root/.config/kitty/kitty.conf \
        && echo "color14 #8FBCBB" >> /root/.config/kitty/kitty.conf \
        && echo "color7  #E5E9F0" >> /root/.config/kitty/kitty.conf \
        && echo "color15 #ECEFF4" >> /root/.config/kitty/kitty.conf

# 7. Ensure Lazy installs plugins
RUN     nvim --headless "+Lazy! sync" +qa || true

# 8. Environment Setup
ENV     TERM=xterm-256color
# Forces software rendering if GPU drivers fail (Essential for GUI in Docker)
ENV     LIBGL_ALWAYS_SOFTWARE=1 

# 9. Launch Kitty which executes Tmux
CMD     ["kitty", "tmux"]
