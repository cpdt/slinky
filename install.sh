#!/bin/bash

# Online installer - downloads required files from the Github repo
install_dir="/usr/local/bin"
download_location="https://raw.githubusercontent.com/cpdt/slinky/master"

echo "Starting Slinky download from $download_location"

# download slink
curl -o- "$download_location/slink" > "$install_dir/slink"
curl -o- "$download_location/rmslink" > "$install_dir/rmslink"
curl -o- "$download_location/lsslink" > "$install_dir/lsslink"
curl -o- "$download_location/slinky-run.sh" > "$install_dir/slinky-run.sh"
curl -o- "$download_location/relativepath.sh" > "$install_dir/relativepath.sh"

echo "Updating permissions"
chmod u+rx "$install_dir/slink"
chmod u+rx "$install_dir/rmslink"
chmod u+rx "$install_dir/lsslink"
chmod u+r "$install_dir/slinky-run.sh"
chmod u+r "$install_dir/relativepath.sh"

echo "Creating Slinky command links for Windows use..."
eval "$install_dir/slink" slink
eval "$install_dir/slink" rmslink
eval "$install_dir/slink" lsslink

echo "Finished installing Slinky!"
echo
echo "NEXT STEPS:"
echo " 1. Add C:\\.slinky to your PATH in Windows"
echo " 2. Use slink <command> to bind a command, and rmslink <command> to remove a command"
echo " 3. Star Slinky on Github at https://github.com/cpdt/slinky"
echo " 4. Enjoy your brand-new command-prompt powers :)"
