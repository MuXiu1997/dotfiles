#!/usr/bin/env bash

set -e

tmpdir=$(mktemp -d)
trap 'rm -rf ${tmpdir}' EXIT

if [[ "$(/usr/bin/uname -m)" == "arm64" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
else
    export PATH="/usr/local/bin:$PATH"
fi

# ensure chezmoi
if [ ! "$(command -v chezmoi)" ]; then
    bash -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$tmpdir"
fi

# ensure bitwarden-cli
if [ ! "$(command -v bw)" ]; then
    bw="$tmpdir/bw"
    curl -sL -o "$tmpdir/bw.zip" 'https://vault.bitwarden.com/download/?app=cli&platform=macos'
    unzip "$tmpdir/bw.zip" -d "$tmpdir"
    chmod +x "$bw"
else
    bw=bw
fi

# config bitwarden and login
$bw config server https://bw.muxiu1997.com
$bw logout || true
BW_SESSION=$($bw login --raw)

# chezmoi init
bash -c "PATH=$tmpdir:$PATH BW_SESSION=$BW_SESSION chezmoi init --apply --verbose MuXiu1997"
