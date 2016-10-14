#!/bin/bash
stub_version='3.0.0'
CMD_ARGUMENTS=$@

function array_contains {
    local e
    for e in "${@:2}"; do [[ "$e" == "$1" ]] && return 0; done
    return 1
}
function read_question {
    local read_value
    echo -ne "\e[36;1m$1 \e[0m\e[33m[$2]\e[0m : "
    read read_value
    if [ -z "$read_value" ]; then read_value="$2"; fi
    RETURN="$read_value"
}

function load_version {
    INSTALL_VER=$1
    if [ "$1" == "local" ]; then
        #cat "./install-version.sh" | bash -s -- $CMD_ARGUMENTS
        INSTALL_VER="develop"
        eval "$(cat ./install-version.sh)"
        exit
    fi

    ROOT_URL="https://raw.githubusercontent.com/cpdt/slinky/$1"
    # todo, clean up
    EXECUTE_SCRIPT=$(curl -s --fail "$ROOT_URL/install-version.sh") || EXECUTE_SCRIPT=$(curl -s --fail "$ROOT_URL/install.sh") || {
        # display warning for powershell installer versions
        echo ""
        echo "The specified version uses the old, Powershell-based installer."
        echo "This installer has some issues installing on Bash on Ubuntu for Windows (other Bash installs work fine), and can be installed by running the following command in the Windows CMD:"
        echo ""
        echo -e "\e[33m  @powershell -NoProfile -ExecutionPolicy Bypass -Command \"iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/cpdt/slinky/$1/install.ps1'))\""
        exit 1
    }

    eval "$EXECUTE_SCRIPT"
    #echo "$EXECUTE_SCRIPT" | bash -s -- "--install_version=$1" $CMD_ARGUMENTS
    exit $?
}

for i in "$@"; do
    case $i in
        -V|--version)
            echo $stub_version
            exit
            ;;
        -i=*|--install=*)
            INSTALL_VER="${i#*=}"
            ;;
        
    esac
done

TAG_CMD='curl -s "https://api.github.com/repos/cpdt/slinky/tags" | grep -Po '"'"'"name":\s*"\K.*?(?=")'"'"' -'
{
    TAG_JSON="$(curl -s 'https://api.github.com/repos/cpdt/slinky/tags')" &&
    BRANCH_JSON="$(curl -s 'https://api.github.com/repos/cpdt/slinky/branches')"
} || {
    echo -e ""
    echo -e "\e[31;1mOops!"
    echo -e "Couldn't fetch the list of versions. You may not be connected to the Internet, or Github may be down.\e[0m"
    exit 1
}

OLD_IFS="$IFS"

# extract tag/branch names
TAG_NAMES="$(echo $TAG_JSON | grep -Po '\"name\":\s*\"\K.*?(?=\")' -)"
BRANCH_NAMES="$(echo $BRANCH_JSON | grep -Po '\"name\":\s*\"\K.*?(?=\")' -)"
IFS=$'\n'; read -rd '' -a TAG_ARRAY <<< "$TAG_NAMES"
IFS=$'\n'; read -rd '' -a BRANCH_ARRAY <<< "$BRANCH_NAMES"
VERSIONS=( "${TAG_ARRAY[@]}" "${BRANCH_ARRAY[@]}" "local" )

IFS={$OLD_IFS}

function rep_loop {
    if [ -z ${INSTALL_VER+x} ]; then
        echo -e ""
        echo -e "Available versions: \e[33m${VERSIONS[@]}"
        read_question "Version to install" "${VERSIONS[0]}"
        SELECTED_VERSION="$RETURN"
        array_contains "$SELECTED_VERSION" "${VERSIONS[@]}" && load_version $SELECTED_VERSION || {
            echo -e "\e[31;1mPlease provide a valid version.\e[0m"
            rep_loop
        }
    else
        array_contains "$INSTALL_VER" "${VERSIONS[@]}" && load_version $INSTALL_VER || {
            echo "Unknown version $INSTALL_VER"
            exit 1
        }
    fi
}
rep_loop