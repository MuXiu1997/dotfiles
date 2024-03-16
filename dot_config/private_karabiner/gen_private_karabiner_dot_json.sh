#!/usr/bin/env bash
set -eufo pipefail

script_dir="$(dirname "$0")"
karabiner_ts="$script_dir/karabiner.ts"
deno fmt --single-quote=true --no-semicolons=true "$karabiner_ts"
deno run "$karabiner_ts" > "$script_dir/private_karabiner.json"
