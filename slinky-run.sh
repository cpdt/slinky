#!/bin/bash

source "$(dirname $0)/slinky.cfg"

initial_directory=$PWD
eval "$*"
bash "$(dirname "$0")/relativepath.sh" "$initial_directory" "$PWD" > "$install_dir/.dirchange"
