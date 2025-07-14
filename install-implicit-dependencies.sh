#!/usr/bin/env zsh
# purpose: installs additional dependencies the user defines in their configuration files.
# example: the font package used by the terminal emulator is not tracked by the system package manager.
# usage: use with dotfiles repo

# ~/.dotfiles/package/.ideps.yml
# ideps:
#   ripgrep:
#     desc: "search for telescope"
#     managers: { any: ripgrep }
#
#   clangd:
#     desc: "C++ LSP"
#     managers:
#       brew: llvm
#       apt: clangd
#       pacman: clang

pkg_managers=(brew apt)
for mg in "${(@)pkg_managers}"; do
done
pkg_manager=
