#!/bin/bash

set -x

# Prepare pacman keyring (idempotent) to avoid PGP trust errors in CI
sudo bash -c 'command -v timedatectl >/dev/null 2>&1 && timedatectl set-ntp true || true'
sudo pacman-key --init || true
sudo pacman-key --populate archlinux || true
sudo pacman -Sy --needed --noconfirm archlinux-keyring
sudo pacman -Scc --noconfirm || true

sudo chown -R build:build /workdir/pkgs

PIKAUR_CMD="PKGDEST=/workdir/pkgs pikaur --noconfirm --build-gpgdir /etc/pacman.d/gnupg -S -P /workdir/${1}/PKGBUILD"
PIKAUR_RUN=(bash -c "${PIKAUR_CMD}")
"${PIKAUR_RUN[@]}"
# remove any epoch (:) in name, replace with -- since not allowed in artifacts
find /workdir/pkgs/*.pkg.tar* -type f -name '*:*' -execdir bash -c 'mv "$1" "${1//:/--}"' bash {} \;