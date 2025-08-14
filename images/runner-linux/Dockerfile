FROM ghcr.io/luiz-monad/ffmpeg-builds/runner-base AS base
FROM ubuntu:24.04
ENV RUNNER=linux

ENV DEBIAN_FRONTEND=noninteractive
RUN \
    apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get -y install \
        build-essential yasm nasm xxd pkgconf curl wget unzip zip git subversion mercurial rsync jq \
        autoconf automake libtool libtool-bin autopoint gettext cmake clang meson ninja-build \
        texinfo texi2html help2man flex bison groff \
        gperf itstool ragel libc6-dev zlib1g-dev libssl-dev \
        gtk-doc-tools gobject-introspection gawk \
        ocaml ocamlbuild libnum-ocaml-dev indent p7zip-full \
        python3-setuptools python3-pip python3-venv python3-jinja2 python3-jsonschema python3-apt \
        python-is-python3 && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/*

RUN git config --global user.email "builder@localhost" && \
    git config --global user.name "Builder" && \
    git config --global advice.detachedHead false

COPY --from=base /runner/install-node.sh /usr/bin/
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
