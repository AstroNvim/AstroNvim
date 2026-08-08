#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
exec "${NVIM:-nvim}" -l "$script_dir/clear_test_environment.lua"
