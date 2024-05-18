#!/usr/bin/env bash

set -eu -o pipefail

nvchecker -c nvchecker.toml -l warning --failures
nvcmp -c nvchecker.toml
