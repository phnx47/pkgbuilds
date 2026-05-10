#!/usr/bin/env bash

set -euo pipefail

cd "$(dirname "$0")/.."

nvchecker -c nvchecker.toml -l warning --failures
nvcmp -c nvchecker.toml
