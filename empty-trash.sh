#!/bin/sh

# purpose: clear cache and trash
# usage: run as chron job 

main() {
  darwin_cache="$HOME/Library/Caches/"
  darwin_trash="$HOME/.Trash"
  xdg_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
  xdg_trash="$XDG_DATA_HOME/Trash"
  
  for d in "$xdg_cache" "$darwin_trash" "$darwin_cache" "$xdg_trash"; do
    if [ -d "$d" ]; then
      find "$d" -mindepth 1 -delete || printf '%s\n' "> [ERROR]: Failed to empty ${d}" >&2
    fi
  done
  
  if command -v apt > /dev/null 2>&1; then
    sudo apt clean -y
  fi
  
  if command -v brew > /dev/null 2>&1; then
    brew cleanup
  fi

  return 0
}

main "$@"
