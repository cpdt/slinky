#!/bin/bash

# Online installer - downloads required files from the Github repo
install_dir="/usr/local/bin"
download_location="https://raw.githubusercontent.com/cpdt/slinky/1.1"

echo "Starting Slinky download from $download_location"

downloads=('slink' 'rmslink' 'lsslink' 'delslink' 'slinky-run.sh' 'relativepath.sh' 'slinky.cfg')

for file in "${downloads[@]}"; do
  echo "Downloading $download_location/$file"
  curl -o- -# "$download_location/$file" > "$install_dir/$file"
  chmod u+rx "$install_dir/$file"
done

echo "Creating Slinky command links for Windows use..."
eval "$install_dir/slink" slink
eval "$install_dir/slink" rmslink
eval "$install_dir/slink" lsslink
eval "$install_dir/slink" delslink

echo "Finished installing Slinky!"
echo
echo "NEXT STEPS:"
echo " 1. Add C:\\.slinky to your PATH in Windows"
echo " 2. Use slink <command> to bind a command, and rmslink <command> to remove a command"
echo " 3. Star Slinky on Github at https://github.com/cpdt/slinky"
echo " 4. Enjoy your brand-new command-prompt powers :)"
