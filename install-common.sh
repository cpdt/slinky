#!/bin/bash

echo "Creating Slinky command links for Windows use..."
bash "$(dirname $0)/slink" slink
bash "$(dirname $0)/slink" rmslink
bash "$(dirname $0)/slink" lsslink
bash "$(dirname $0)/slink" delslink

echo "Finished installing Slinky!"
echo
echo "NEXT STEPS:"
echo " 1. Add C:\\.slinky to your PATH in Windows"
echo " 2. Run slink <command> to bind a command, and rmslink <command> to remove a command"
echo " 3. Star Slinky on Github at https://github.com/cpdt/slinky"
echo " 4. Enjoy your brand-new command-prompt powers :)"

# remove this file as it is no longer necessary
rm $0