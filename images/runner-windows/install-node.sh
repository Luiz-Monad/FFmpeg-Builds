#!/bin/bash
set -xe

pacman --noconfirm -S nodejs npm

pacman -Scc --noconfirm
rm -rf /var/cache/pacman/pkg/*
