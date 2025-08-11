#!/bin/bash
set -xe

mkdir -p "${CARGO_HOME}"
curl https://sh.rustup.rs -sSf | bash -s -- -y --no-modify-path 
cargo install cargo-c 
rm -rf "${CARGO_HOME}"/registry "${CARGO_HOME}"/git
