#!/usr/bin/env bash

set -e

tmpdir=$(mktemp -d)
trap 'rm -rf ${tmpdir}' EXIT

export PATH="$tmpdir:/home/linuxbrew/.linuxbrew/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

# ensure chezmoi
if [ ! "$(command -v chezmoi)" ]; then
    bash -c "$(curl -fsSL https://git.io/chezmoi)" -- -b "$tmpdir"
fi

# chezmoi init
chezmoi init --apply --verbose MuXiu1997
