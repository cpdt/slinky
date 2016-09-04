#!/bin/bash

# Local installer - assumes all required files are in the current directory
install_dir="/usr/local/bin"

echo "Starting Slinky local install from $(pwd) to $install_dir"

downloads=('slink' 'rmslink' 'lsslink' 'delslink' 'slinky-run.sh' 'relativepath.sh' 'slinky.cfg' 'install-common.sh')

for file in "${downloads[@]}"; do
  echo "Copying $(pwd)/$file to $install_dir/$file"
  cp "$(pwd)/$file" "$install_dir/$file"
  chmod u+rx "$install_dir/$file"
done

bash "$install_dir/install-common.sh"