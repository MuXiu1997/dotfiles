#!/bin/sh

set -e

tmpdir=$(mktemp -d)
trap 'rm -rf ${tmpdir}' EXIT

if [ ! "$(command -v chezmoi)" ]; then
    sh -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$tmpdir"
fi

if [ ! "$(command -v bw)" ]; then
    bw="$tmpdir/bw"
    bw_version=$(curl -fsSL -o /dev/null -w "%{url_effective}" "https://github.com/bitwarden/cli/releases/latest" | awk -v FS='/' '{print $NF}' | cut -c 2-)
    curl -w '%{http_code}' -sL -o  "$tmpdir/bw-macos-$bw_version.zip" "https://github.com/bitwarden/cli/releases/download/v$bw_version/bw-macos-$bw_version.zip"
    unzip "$tmpdir/bw-macos-$bw_version.zip"
    chmod +x "$bw"
else
    bw=bw
fi

$bw config server https://bw.muxiu1997.com
$bw logout || true
BW_SESSION=$($bw login --raw)

sh -c "PATH=$tmpdir:$PATH BW_SESSION=$BW_SESSION chezmoi init --apply -v MuXiu1997"
