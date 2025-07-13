#!/usr/bin/env zsh
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [-n] [-d DIR]

A script to automatically update the YAML frontmatter of markdown files.

  -d DIR    The root directory of your notes vault to scan.
            (Default: "$HOME/Documents/notes")
  -n        Dry-run mode. Print what would be changed without modifying files.
  -h        Show this help message.
EOF
}

scrape_tags() {
  local parent_path="$1"
  local file_path="$2"

  local relative_dir_path
  relative_dir_path=${${file_path:h}#$parent_path/}

  [[ -z "$relative_dir_path" || "$relative_dir_path" == "$parent_path" ]] && return 0

  print -l -- ${(L)${${(s:/:)relative_dir_path}// /-}}
}

scrape_title() {
  print "${(C)${${1##*/}%%.md}//-/ }"
}

build_awk_processor() {
  cat <<'AWK'

function yaml_quote(str) {
    gsub(/"/, "\\\"", str)
    return "\"" str "\""
}

function print_merged_tags() {
    for (tag in existing_tags) all_tags[tag] = 1
    for (i in new_tags_arr) {
        if (new_tags_arr[i] != "") all_tags[new_tags_arr[i]] = 1
    }

    if (length(all_tags) == 0) {
        tags_processed = 1
        return
    }

    asorti(all_tags, sorted_tags)

    print "tags:"
    for (i in sorted_tags) {
        print "  - " sorted_tags[i]
    }
    tags_processed = 1
}

BEGIN {
    in_front_matter = 0   
    front_matter_ended = 0
    in_tags_section = 0   

    title_found = 0
    tags_processed = 0

    split(new_tags, new_tags_arr, "\n")
}


NR == 1 && $0 !~ /^---$/ {
    print "---"
    if (title != "") {
        print "title: " yaml_quote(title)
    }
    print_merged_tags()
    print "---"
    front_matter_ended = 1
    in_front_matter = 0
}

/^---$/ {
    if (!in_front_matter && !front_matter_ended) {
        in_front_matter = 1
    } else if (in_front_matter) {
        if (!title_found && title != "") print "title: " yaml_quote(title)
        if (!tags_processed) print_merged_tags()

        in_front_matter = 0
        front_matter_ended = 1
    }
    print
    next 
}

in_front_matter {
    if ($1 == "title:") {
        title_found = 1
        if (in_tags_section) {
            print_merged_tags()
            in_tags_section = 0
        }
    }

    else if ($1 == "tags:" || $0 ~ /^tags: *\[\] *$/) {
        if (in_tags_section) {
            print_merged_tags()
        }
        in_tags_section = 1
        next
    }

    else if (in_tags_section) {
        if ($1 == "-" && $2 != "") {
            existing_tags[$2] = 1
            next
        } else {
            print_merged_tags()
            in_tags_section = 0
        }
    }
    print
    next
}

END {
    if (in_tags_section) {
        print_merged_tags()
    }
}

{ print }
AWK
}

main() {
  local parent_path="$HOME/Documents/notes"
  local dry_run=0

  while getopts ":d:nh" opt; do
    case ${opt} in
      d ) parent_path="$OPTARG" ;;
      n ) dry_run=1 ;;
      h ) usage; exit 0 ;;
      \? ) echo "Invalid option: -$OPTARG" >&2; usage; exit 1 ;;
    esac
  done

  if ! [[ -d "$parent_path" ]]; then
    print "Error: Directory '$parent_path' not found." >&2
    exit 1
  fi

  if (( dry_run )); then
    print "=== DRY RUN MODE ENABLED ==="
    print "Scanning directory: $parent_path"
    print "No files will be modified.\n"
  fi

  local file
  while read -r -d '' file; do
    local mime_type
    mime_type=$(file -b --mime-type "$file")
    if [[ "$mime_type" != text/* && "$mime_type" != "application/json" ]]; then
        print -- "--- Skipping non-text file: $file ($mime_type)"
        continue
    fi

    local title
    title="$(scrape_title "$file")"
    local tags
    tags="$(scrape_tags "$parent_path" "$file")"

    print -- "--- Processing: $file"
    print "  - Derived Title: $title"
    print "  - Derived Tags:  ${(j:, :)tags}"

    if (( dry_run )); then
      print "  - SKIPPING modification (dry run)."
      continue
    fi

    local tmp_file="${file}.tmp"
    gawk -v title="$title" -v new_tags="$tags" -f <(build_awk_processor) "$file" > "$tmp_file"

    if [[ $? -eq 0 && -s "$tmp_file" ]]; then
      mv "$tmp_file" "$file"
      print "  - SUCCESS: Updated $file"
    else
      print "  - ERROR: awk processing failed for $file. Original file is unchanged." >&2
      rm -f "$tmp_file"
    fi
    print ""

  done < <(find "$parent_path" -type f -name "*.md" -print0)
}

main "$@"
