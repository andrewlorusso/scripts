#!/usr/bin/env zsh

main() {
  local dependencies=(jq curl wlsunset notify-send); missing=(); dep
  
  for dep in "${(@)dependencies}"; do
    if ! command -v "$dep" &> /dev/null; then
      missing+=("$dep")
    fi
  done
  
  if (("${#missing}")); then
    print "> Error: Missing ${(@)missing}" >&2
    return 1
  fi
  
  local geo_data="$(curl -s --fail --max-time 5 http://ip-api.com/json/ || return 1)" 
  local latitude="$(jq -r .lat <<< "$geo_data")"
  local longitude="$(jq -r .lon <<< "$geo_data")"
  
  
  if [[ -z "$latitude" ]] || [[ -z "$longitude" ]]; then
    print '> Error: Failed to parse latitude or longitude' >&2
    return 1
  fi

  if wlsunset -l "$latitude" -L "$longitude" --daemon; then
    print "> [INFO] wlsunset started successfully in the background" >&2
  else
    notify-send "wlsunset Error" "Failed to start wlsunset daemon"
    return 1
  fi

  return 0
}

main "$@"
