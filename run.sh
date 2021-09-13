#!/bin/zsh

# If any part of this script fails, exit immediately
set -e

# Initialize variables
local -i SHOW_HELP=0
local -i SKIP_ESSENTIALS=0
local -i SKIP_BREW=0
local -i SKIP_MAS=0

# Usage
function displayUsage {
    cat <<'EOFFOE'
Usage:      ./init-macos.sh     <flags>

Purpose:    Completely set up a fresh macOS install with specified tools

  -h        Show usage (this output) and quit immediately
  -e        Skip essential installs and SSH key generation
            It is not recommended to use this flag since the script will
            automatically check if brew is installed and if the SSH key already
            exists. If they do, then the script will skip installation and
            generation.
  -b        Skip brew app installation
  -m        Skip mas app installation
EOFFOE
}

# Check for flags
while getopts "h?ebcm" option
do
  case "$option" in
    h|\?)
      SHOW_HELP=1
      ;;
    e)
      SKIP_ESSENTIALS=1
      ;;
    b)
      SKIP_BREW=1
      ;;
    m)
      SKIP_MAS=1
      ;;
    *)
      echo "Invalid flags specified."
      echo "Please check the correct usage and try again."
      echo ""
      displayUsage
      return
      ;;
      esac
done

# Check if user wants help
if (( SHOW_HELP )) then
  displayUsage
  return
fi

# PART 1 - ESSENTIALS
if ! (( SKIP_ESSENTIALS )) then
  # Install homebrew (if it is not already installed)
  if ! type brew; then
    echo "[ESSENTIALS] Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    echo "[ESSENTIALS] Homebrew already seems to be installed. Skipping..."
  fi


  # Generate SSH keys (if not present)
  if [[ ! -a ~/.ssh/id_rsa ]]; then
    echo "[ESSENTIALS] Generating SSH key..."
    ssh-keygen -t rsa
  else
    echo "[ESSENTIALS] SSH key found. Skipping..."
  fi
else
  echo "[ESSENTIALS] Skipping essential install on request..."
fi

# FUNCTION: install apps from brew
# Usage: brew_install <package_name>
function brew_install {
  echo -e "[BREW] Installing $1..."
  brew install $1
}

# FUNCTION: install apps from mas
# Usage: mas_install <app_id> <app_name (display only)>
function mas_install {
   echo -e "[MAS] Installing $2..."
   mas install $1 &
}

# PART 2 - Install brew apps
if ! (( SKIP_BREW )) then
  while IFS= read -r line; do
    brew_install $line
  done < "list/brew_programs.txt"
else
  echo "[BREW] Skipping brew programs installation on request..."
fi

# PART 3 - Install MAS apps
if ! (( SKIP_MAS )) then
  # Warning about mas
  echo "[MAS] Starting installation of apps from the Mac App Store..."
  echo "[MAS] WARNING: If this is your first time downloading these apps, installation will fail because there will be no purchase history."
  echo "[MAS] It is therefore recommended that you first download the apps through the App Store."
  echo "[MAS] Subsequent script runs will automatically find and download those apps from your purchase history."

  # Install mas apps
  while IFS= read -r line; do
    mas_install $(echo $line | tr -d '\n')
  done < "list/mas_programs.txt"

  # Warn about background mas
  echo "[MAS] Background app installation started!"
  echo "[MAS] WARNING: mas is still installing apps in the background."
  echo "[MAS] To see running processes, run ps."
  echo "[MAS] To see download progress, go to the Launchpad."
  echo "[MAS] It is recommended that you do not restart the computer while the commands are running."
else
  echo "[MAS] Skipping brew cask programs installation on request..."
fi

