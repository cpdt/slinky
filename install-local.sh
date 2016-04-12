#!/bin/bash

# Local installer - assumes all required files are in the current directory
install_dir="/usr/local/bin"

echo "Copying files to install location"
cp "./slink" "$install_dir/slink"
cp "./rmslink" "$install_dir/rmslink"
cp "./lsslink" "$install_dir/lsslink"
cp "./slinky-run.sh" "$install_dir/slinky-run.sh"
cp "./relativepath.sh" "$install_dir/relativepath.sh"

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
echo " 2. Run slink <command> to bind a command, and rmslink <command> to remove a command"
echo " 3. Star Slinky on Github at https://github.com/cpdt/slinky"
echo " 4. Enjoy your brand-new command-prompt powers :)"
