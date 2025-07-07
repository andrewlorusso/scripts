#!/usr/bin/env zsh

case "$(command -v md5 2>/dev/null || command -v md5sum 2>/dev/null)" in 
  *md5) hash_cmd=(md5 -q);;
  *md5sum) hash_cmd=(md5sum);;
  *) exit;;
esac

typeset -A hash_title 
for video in *(.); do
  vid_hash="${("${(@)hash_cmd}" "$video")%% *}"
  if [[ -v 'hash_title[$vid_hash]' ]]; then
    print "removing dup: ${video}"
    rm -f "$video"
  fi
  hash_title["$vid_hash"]="$video"
done
