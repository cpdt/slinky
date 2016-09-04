#!/bin/bash

# Online installer - downloads required files from the Github repo
version="1.1"
install_dir="/usr/local/bin"
download_location="https://raw.githubusercontent.com/cpdt/slinky/$version"

echo "Starting Slinky download & install from $download_location to $install_dir"

downloads=('slink' 'rmslink' 'lsslink' 'delslink' 'slinky-run.sh' 'relativepath.sh' 'slinky.cfg' 'install-common.sh')

for file in "${downloads[@]}"; do
  echo "Downloading $download_location/$file"
  curl -o- -# "$download_location/$file" > "$install_dir/$file"
  chmod u+rx "$install_dir/$file"
done

bash "$install_dir/install-common.sh"