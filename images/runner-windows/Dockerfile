FROM ghcr.io/luiz-monad/ffmpeg-builds/runner-base AS base
FROM mcr.microsoft.com/windows/servercore:ltsc2022
ENV RUNNER=windows
ARG BASE=ghcr.io/luiz-monad/ffmpeg-builds/runner-base

SHELL ["powershell", "-Command"]
RUN Set-ExecutionPolicy Bypass -Scope Process -Force ; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 ; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

RUN choco install -y msys2

SHELL ["C:/tools/msys64/usr/bin/bash.exe", "-c"]
        
RUN \
    pacman --noconfirm -Syuu && \
    pacman --noconfirm -Sy && \
    pacman --noconfirm -S \
        base-devel yasm nasm xxd pkgconf curl wget unzip zip git subversion mercurial rsync jq \
        autoconf automake libtool autopoint gettext make cmake clang meson ninja \
        texinfo texi2html help2man flex bison groff \
        gperf itstool ragel zlib openssl \
        gtk-doc gobject-introspection gawk \
        ocaml indent p7zip jinja \
        python python-setuptools python-pip python-virtualenv python-jinja && \
    pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

RUN git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

COPY ./install-node.sh /usr/bin/
RUN install-node.sh

COPY --from=base /runner/install-rust.sh /usr/bin/
ENV CARGO_HOME="/opt/cargo" \
    RUSTUP_HOME="/opt/rustup" \
    PATH="/opt/cargo/bin:${PATH}"
RUN install-rust.sh

COPY --from=base /runner/ /input/
RUN for s in /input/*.sh; do cp "$s" /usr/bin/$(basename "$s" .sh); done
RUN rm -rf /input/

ENV HOST_CC="clang" \
    HOST_CXX="clang++" \
    HOST_CFLAGS="-O2 -pipe" \
    HOST_CXXFLAGS="-O2 -pipe"
