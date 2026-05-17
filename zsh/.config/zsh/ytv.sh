#!/usr/bin/env bash

die() {
  printf "\033[1;31m%s\033[0m\n" "$*" >&2
}

cancel() {
  echo "canceled"
  exit
}

launcher() {
  fzf --prompt="${1}" --border=rounded --layout=reverse --height="${2}"
}

main() {
  local query
  query="${1}"

  if [ -z "${query}" ]; then
    read -rp "Enter search query: " query
    [ -z "${query}" ] && die "Search query must not be empty"
  fi

  echo -e "Searching for '\e[1;33m${query}\e[0m'..."

  local selected video_id quality format

  selected=$(yt-dlp "ytsearch50:${query}" --flat-playlist --print "%(title)s :: %(uploader)s :: %(id)s" 2>/dev/null | launcher "Select video: " "80%" --delimiter=" :: " --with-nth=1,2)
  [ -z "${selected}" ] && cancel

  video_id=$(echo "${selected}" | awk -F ' :: ' '{print $NF}')
  quality=$(printf "1. 1080p\n2. 720p\n3. Best available\n" | launcher "Quality: " "10")
  [ -z "${quality}" ] && cancel

  case "${quality}" in
    "1080p") format="bestvideo[height<=1080]+bestaudio/best" ;;
    "720p") format="bestvideo[height<=720]+bestaudio/best" ;;
    "480p") format="bestvideo[height<=480]+bestaudio/best" ;;
    "360p") format="bestvideo[height<=360]+bestaudio/best" ;;
    *) format="bestvideo+bestaudio/best" ;;
  esac

  mpv --ytdl-format="${format}" --hwdec=auto-safe "https://www.youtube.com/watch?v=${video_id}" >/dev/null 2>&1
}

main "$@"