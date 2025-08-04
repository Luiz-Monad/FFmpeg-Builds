FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]
RUN Set-ExecutionPolicy Bypass -Scope Process -Force ; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12 ; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

RUN choco install -y msys2

SHELL ["C:/tools/msys64/usr/bin/bash.exe", "-c"]

RUN pacman --noconfirm -Syuu && \
    pacman --noconfirm -Sy && \
    pacman --noconfirm -S \
    base-devel git curl wget unzip zip rsync jq p7zip \
    autoconf automake libtool pkgconf \
    clang cmake meson ninja make nasm yasm xxd \
    python python-pip python-setuptools python-virtualenv python-jinja jinja \
    gettext gperf flex bison texinfo texi2html help2man groff \
    gawk gobject-introspection gtk-doc ocaml indent ragel itstool \
    zlib openssl \
        subversion mercurial \
        nodejs npm

RUN git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

ENV CARGO_HOME="/opt/cargo" RUSTUP_HOME="/opt/rustup" PATH="/opt/cargo/bin:${PATH}"
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path && \
    cargo install cargo-c && rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git

COPY --from=ghcr.io/luiz-monad/ffmpeg-builds/runner-base /runner/ /input/
RUN for s in /input/*.sh; do cp "$s" /usr/bin/$(basename "$s" .sh); done
RUN rm -rf /input/

ENV HOST_CC="clang" \
    HOST_CXX="clang++" \
    HOST_CFLAGS="-O2 -pipe" \
    HOST_CXXFLAGS="-O2 -pipe"
