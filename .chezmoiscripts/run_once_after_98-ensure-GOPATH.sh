#!/usr/bin/env bash
set -eufo pipefail

XDG_DATA_HOME="$HOME/.local/share"
GOPATH="$XDG_DATA_HOME/go"
mkdir -p "$GOPATH/src" "$GOPATH/bin" "$GOPATH/pkg"
