#!/usr/bin/env bash

set -euo pipefail

nvchecker -c nvchecker.toml -l warning --failures
nvcmp -c nvchecker.toml
