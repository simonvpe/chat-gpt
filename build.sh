#!/usr/bin/env bash

readonly width=120
readonly chunk_size=4096

main() {
  mkdir -p gen/
  cat transcript.json | extract-text | extract-chunks | tee gen/transcript.txt
}

extract-text() {
  jq -r '[..|.transcriptSegmentRenderer?|select(.)|..|.text?|select(.)]|join(" ")' | tr '\n' ' ' | sed 's/\./.\n/g'
}

extract-chunks() {
  buffer=""
  while read -r line; do
    let buffer_sz=${#buffer}
    let line_sz=${#line}
    let total_sz=buffer_sz+line_sz
    if [ "$total_sz" -lt "$chunk_size" ]; then
      buffer="$buffer $line";
    else
      printf '%s\n\n\n\n' "$buffer $line" | sed 's/^ //g' | fmt -w "$width"
      buffer=""
    fi
  done < <(cat)
}

main
