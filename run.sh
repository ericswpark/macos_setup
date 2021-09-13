#!/bin/zsh

# If any part of this script fails, exit immediately
set -e

# Initialize variables
local -i SHOW_HELP=0
local -i SKIP_ESSENTIALS=0
local -i SKIP_BREW=0
local -i SKIP_MAS=0

# FUNCTION: Usage display
function displayUsage {
    cat <<'EOFFOE'
Usage:      ./init-macos.sh     <flags>

Purpose:    Completely set up a fresh macOS install with specified tools

  -h        Show usage (this output) and quit immediately
  -e        Skip essential installs and SSH key generation
            Only use this flag if your SSH key is not named id_rsa and you
            wish to skip automatic detection of your SSH key. If brew is not
            installed, the rest of the modules will fail.
  -b        Skip brew app installation
  -m        Skip mas app installation
EOFFOE
}

# FUNCTION: Logger
# Usage: log <module_name> <log>
function log {
    echo -e "[$1] $2"
}

# FUNCTION: Essentials logger
# Usage log_e <log>
function log_e {
    log "ESSENTIALS" $1
}

# FUNCTION: Brew logger
# Usage log_b <log>
function log_b {
    log "BREW" $1
}

# FUNCTION: MAS logger
# Usage log_m <log>
function log_m {
    log "MAS" $1
}

# FUNCTION: install apps from brew
# Usage: brew_install <package_name>
function brew_install {
  log_b "Installing $1..."
  brew install $1
}

# FUNCTION: install apps from mas
# Usage: mas_install <app_id> <app_name (display only)>
function mas_install {
    log_m "Installing $2..."
    mas install $1 &
}

# --------
# | MAIN |
# --------

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
    log_e "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  else
    log_e "Homebrew already seems to be installed. Skipping..."
  fi


  # Generate SSH keys (if not present)
  if [[ ! -a ~/.ssh/id_rsa ]]; then
    log_e "Generating SSH key..."
    ssh-keygen -t rsa
  else
    log_e "SSH key found. Skipping..."
  fi
else
  log_e "Skipping essential install on request..."
fi

# PART 2 - Install brew apps
if ! (( SKIP_BREW )) then
  while IFS= read -r line; do
    brew_install $line
  done < "list/brew_programs.txt"
else
  log_b "Skipping brew programs installation on request..."
fi

# PART 3 - Install MAS apps
if ! (( SKIP_MAS )) then
  # Warning about mas
  log_m "Starting installation of apps from the Mac App Store..."
  log_m "WARNING: If this is your first time downloading these apps, installation will fail because there will be no purchase history."
  log_m "It is therefore recommended that you first download the apps through the App Store."
  log_m "Subsequent script runs will automatically find and download those apps from your purchase history."

  # Install mas apps
  while IFS= read -r line; do
    mas_install $(echo $line | tr -d '\n')
  done < "list/mas_programs.txt"

  # Warn about background mas
  log_m "Background app installation started!"
  log_m "WARNING: mas is still installing apps in the background."
  log_m "To see running processes, run ps."
  log_m "To see download progress, go to the Launchpad."
  log_m "It is recommended that you do not restart the computer while the commands are running."
else
  log_m "Skipping Mac App Store programs installation on request..."
fi

