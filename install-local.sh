#!/bin/bash

# Local installer - assumes all required files are in the current directory
install_dir="/usr/local/bin"

downloads=('slink' 'rmslink' 'lsslink' 'delslink' 'slinky-run.sh' 'relativepath.sh' 'slinky.cfg')

for file in "${downloads[@]}"; do
  echo "Copying ./$file to $install_dir/$file"
  cp "./$file" "$install_dir/$file"
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
echo " 2. Run slink <command> to bind a command, and rmslink <command> to remove a command"
echo " 3. Star Slinky on Github at https://github.com/cpdt/slinky"
echo " 4. Enjoy your brand-new command-prompt powers :)"
