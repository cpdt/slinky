#!/bin/bash

initial_directory=$PWD
eval "$*"
eval '$(dirname "$0")/relativepath.sh' "$initial_directory" "$PWD" > "/mnt/c/.slinky/.dirchange"
