#!/bin/bash

function display_help {
    echo "Usage: install.sh [-h|--help] [-a|--auto] [-b|--bash=<path>] [-d|--dest=<path>] [-l|--linkdir=<path>] [-p|--prepend=<val>]"
    echo "                  "
    echo ""
    echo "Installs Slinky ($INSTALL_VER) on the system. Any parameters not provided are prompted"
    echo " for before beginning installation."
    echo ""
    echo "  -h, --help"
    echo "    Display this help message."
    echo "  -a, --auto"
    echo "    Just install it, no questions asked - uses default parameters if not provided."
    echo "  -b=<path>, --bash=<path>"
    echo "    The (Windows) path to the Bash executable."
    echo "  -d=<path>, --dest=<path>"
    echo "    The (Linux) directory to download and install the commands to."
    echo "  -l=<path>, --linkdir=<path>"
    echo "    The (Linux) directory to place links in, must be accessible from Windows side."
    echo "  -p=<val>, --prepend=<val>"
    echo "    A value to prepend to all slinked commands (allows multiple installs)."
    exit 1
}

AUTO_MODE=false
BASH_EXE=0
CMD_DEST=0
LINK_DEST=0
PREPEND=0

# parse command-line arguments
for i in "${CMD_ARGUMENTS[@]}"; do
    case $i in
        -h|--help)
            display_help
            ;;
        -a|--auto)
            AUTO_MODE=true
            ;;
        -b=*|--bash=*)
            BASH_EXE="${i#*=}"
            ;;
        -d=*|--dest=*)
            CMD_DEST="${i#*=}"
            ;;
        -l=*|--linkdir=*)
            LINK_DEST="${i#*=}"
            ;;
        -p=*|--prepend=*)
            PREPEND="${i#*=}"
            ;;
    esac
done

DOWNLOAD_LOCATION="https://raw.githubusercontent.com/cpdt/slinky/$INSTALL_VER"

# ask a question - first parameter is the question, second is the default value, third is the parameter value
function read_question {
    local question=$1
    local default=$2
    local passed_val=$3
    local read_value

    if [ "$AUTO_MODE" == "true" ] && [[ $passed_val == 0 ]]; then passed_val="$default"; fi
    echo -ne "\e[36;1m$question \e[0m\e[33m[$default]\e[0m : "
    if [[ $passed_val == 0 ]]; then
        read read_value
        if [ -z "$read_value" ]; then read_value="$default"; fi
    else
        echo "$passed_val"
        read_value="$passed_val"
    fi
    RETURN="$read_value"
}

# displays a coloured configuration property - first parameter is the property name, second is the value
function write_conf {
    echo -e "\e[32;1m  $1\e[30;1m=\e[0m\e[36m$2\e[0m"
}

# runs a command passed as the first parameter, second parameter is whether to continue on failure
function run_cmd {
    eval "$1" || {
        echo -e "\e[31;1m  Failed to run \e[33;1m$1\e[31;1m (error: $?)\e[0m"
        if [ "$2" == "true" ]; then
            echo -e "\e[31m  Continuing anyway\e[0m"
        else
            echo -e "  \e[31mInstallation cannot continue, and has been aborted."
            echo -e "  Slinky is NOT installed.\e[0m"
            exit 1
        fi
    }
}

echo ""
echo "Welcome to the Slinky ($INSTALL_VER) installation script"

# repeat until the user says its ok
while : ; do
    read_question "Bash executable location (as Windows path)" "C:/Windows/System32/bash.exe" "$BASH_EXE"
    BASH_PATH="$RETURN"
    read_question "Install directory (as Linux path)" "/usr/local/bin" "$CMD_DEST"
    CMD_DIR="$RETURN"
    read_question "Link install directory (as Linux path)" "/mnt/$(find /mnt/* -maxdepth 1 -type d -printf %f -quit)/.slinky" "$LINK_DEST"
    LINK_DIR="$RETURN"
    read_question "Text to prepend to Windows commands" '' "$PREPEND"
    COMMAND_PREPEND="$RETURN"

    echo ""
    echo "Here's the contents of slinky.cfg:"
    write_conf "install_dir" "\"$LINK_DIR\""
    write_conf "run_file" "\"$CMD_DIR/slinky-run.sh\""
    write_conf "win_bash" "\"$BASH_PATH\""
    write_conf "command_prepend" "\"$COMMAND_PREPEND\""
    write_conf "use_color" "true"

    read_question "Is this okay?" "Y/n" 0
    CONF_OK="$RETURN"

    [[ "$CONF_OK" != y* ]] && [[ "$CONF_OK" != Y* ]] && {
        echo
        echo "Okay, going again..."
    } || break
done

echo
echo -e "Excellent! Beginning installation from \e[36m$DOWNLOAD_LOCATION\e[0m"

# the installation requires curl in bash, so install it here - some implementations (e.g. Cygwin and Git Bash) don't provide apt-get, meaning this line will fail.
# most of them include curl anyway, so everything else should be fine.
echo -e "\e[32m  Ensuring curl is installed\e[0m"
run_cmd "apt-get install curl -y" true

# make sure the installation path exists
echo -e "\e[32m  Creating installation directory\e[0m"
run_cmd "mkdir -p \"$CMD_DIR\""

# iterate through each file to download, use curl to place it in the correct location, and ensure permissions are correct
DOWNLOADS=( 'slink' 'rmslink' 'lsslink' 'delslink' 'slinky-run.sh' 'relativepath.sh' )
for file in "${DOWNLOADS[@]}"; do
    echo -e "\e[32m  Downloading \e[36m$DOWNLOAD_LOCATION/$file\e[32m to \e[36m$CMD_DIR/$file\e[0m"
    run_cmd "touch \"$CMD_DIR/$file\""
    run_cmd "chmod a+rx \"$CMD_DIR/$file\""
    run_cmd "curl -o- -# \"$DOWNLOAD_LOCATION/$file\" > \"$CMD_DIR/$file\""
done

# create the .dirchange file, used to update the current directory on windows if the bash one changes
echo -e "\e[32m  Setting up link directory\e[0m"
run_cmd "mkdir -p \"$LINK_DIR\""
run_cmd "touch \"$LINK_DIR/.dirchange\""

echo -e "\e[32m  Writing configuration file\e[0m"
run_cmd "echo \"install_dir=\\\"$LINK_DIR\\\"\" > \"$CMD_DIR/slinky.cfg\""
run_cmd "echo \"run_file=\\\"$CMD_DIR/slinky-run.sh\\\"\" >> \"$CMD_DIR/slinky.cfg\""
run_cmd "echo \"win_bash=\\\"$BASH_PATH\\\"\" >> \"$CMD_DIR/slinky.cfg\""
run_cmd "echo \"command_prepend=\\\"$COMMAND_PREPEND\\\"\" >> \"$CMD_DIR/slinky.cfg\""
run_cmd "echo \"use_color=true\" >> \"$CMD_DIR/slinky.cfg\""

echo -e "\e[32m  Creating Slinky command links for Windows use\e[0m"
run_cmd "\"$CMD_DIR/slink\" slink \"$CMD_DIR/slink\""
run_cmd "\"$CMD_DIR/slink\" rmslink \"$CMD_DIR/rmslink\""
run_cmd "\"$CMD_DIR/slink\" lsslink \"$CMD_DIR/lsslink\""
run_cmd "\"$CMD_DIR/slink\" delslink \"$CMD_DIR/delslink\""

# display some fun info
echo -e "\e[32m  Finished installing Slinky!"
echo
echo -e "\e[32;1mNEXT STEPS:\e[0m"
echo -e "\e[32m 1.\e[0m Add \e[36m$LINK_DIR\e[0m to your PATH in Windows"
echo -e "\e[32m 2.\e[0m Run \e[33;1mslink <command>\e[0m to bind a command, and \e[33;1mrmslink <command>\e[0m to remove a command"
echo -e "\e[32m 3.\e[0m Star Slinky on Github at \e[36mhttps://github.com/cpdt/slinky"
echo -e "\e[32m 4.\e[0m Enjoy your brand-new command-prompt powers :)"
