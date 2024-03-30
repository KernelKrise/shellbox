FROM debian:12 as base

# Update and install all necessary tools
RUN apt update -y && apt upgrade -y

RUN apt install -y curl wget git neovim tmux tree net-tools binutils file zsh htop

# Install and configure python
RUN apt install -y python3 python3-pip

RUN rm /usr/lib/python3.11/EXTERNALLY-MANAGED

# Set custom banner
COPY banner.txt /etc/motd

# Install and configure oh my zsh
RUN wget -q https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O /tmp/install_ohmyzsh.sh

RUN sh /tmp/install_ohmyzsh.sh --unattended

RUN chsh -s /usr/bin/zsh root

RUN echo 'export PATH=$PATH:/sbin' >> /root/.zshrc

RUN sed -i 's/robbyrussell/eastwood/g' /root/.zshrc

RUN sed -i 's/plugins=\(git\)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' /root/.zshrc

RUN git clone https://github.com/zsh-users/zsh-autosuggestions /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions

RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

RUN rm /root/.oh-my-zsh/themes/*

COPY eastwood.zsh-theme /root/.oh-my-zsh/themes/eastwood.zsh-theme

RUN echo 'export LC_CTYPE=C.UTF-8' >> /root/.zshrc

RUN rm /tmp/install_ohmyzsh.sh

# Configure neovim
RUN mkdir -p /root/.config/nvim

COPY init.vim /root/.config/nvim/init.vim

# Configure tmux
COPY tmux.conf /root/.tmux.conf

# Install tools on python
RUN pip3 install ipython requests

# --------- Copy to final image ---------
FROM debian:12

COPY --from=base / /

WORKDIR /app

# Run zsh as default
CMD ["zsh"]

# docker build . -t kernelkrise/shellbox:basic
