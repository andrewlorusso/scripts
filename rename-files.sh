#!/bin/sh
# purpose: standardized naming conventions on a system
# example: 'My File.txt' -> 'my-file.txt'

target="$1"

find "$target" -type f -print0 | while read -r -d '' file; do
  new_name="$(echo "${file##*/}" | sed 's/ /-/g' | tr [:upper:] [:lower:])"
  base_dir="${file%/*}"

  if [ -e "${base_dir}/${new_name}" ]; then
    printf '%s\n' "> [INFO]: Skipping: file with new name already exits ${new_name}" >&2
    continue
  fi
 
  if [ "$file" != "${base_dir}/${new_name}" ]; then
    mv "$file" "${base_dir}/${new_name}"
  fi
done
