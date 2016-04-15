#!/bin/bash

initial_directory=$PWD
eval "$*"
eval '/bin/bash $(dirname "$0")/relativepath.sh' "$initial_directory" "$PWD" > "/mnt/c/.slinky/.dirchange"
