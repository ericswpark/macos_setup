#!/bin/zsh

# If any part of this script fails, exit immediately
set -e

# Initialize variables
local -i SHOW_HELP=0
local -i SKIP_ESSENTIALS=0
local -i SKIP_BREW=0
local -i SKIP_NVM=0
local -i SKIP_BREW_CASK=0
local -i ASK_BREW_CASK=0
local -i SKIP_BREW_DRIVERS=0
local -i SKIP_MAS=0

# FUNCTION: Usage display
function displayUsage {
    cat <<'EOFFOE'
Usage:      ./run.sh    <flags>

Purpose:    Completely set up a fresh macOS install with specified tools

  -h        Show usage (this output) and quit immediately
  -e        Skip essential installs and SSH key generation
            Only use this flag if your SSH key is not named id_rsa and you
            wish to skip automatic detection of your SSH key. If brew is not
            installed, the rest of the modules will fail.
  -b        Skip brew app installation
  -n        Skip NVM (Node Version Manager) installation
  -c        Skip brew cask app installation
  -a        Ask for confirmation before installing each brew cask entry
  -d        Skip brew driver installation
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

# FUNCTION: Brew cask logger
# Usage log_c <log>
function log_c {
    log "BREWCASK" $1
}

# FUNCTION: Brew driver logger
# Usage log_d <log>
function log_d {
    log "BREWDRIVER" $1
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

# FUNCTION: install apps from brew cask
# Usage: brew_cask_install <package_name>
function brew_cask_install {
  log_c "Installing $1..."
  brew install --cask $1
}

# FUNCTION: install drivers from brew
# Usage: brew_driver_install <package_name>
function brew_driver_install {
  log_d "Installing $1..."
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
while getopts "h?ebncadm" option
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
    n)
      SKIP_NVM=1
      ;;
    c)
      SKIP_BREW_CASK=1
      ;;
    a)
      ASK_BREW_CASK=1
      ;;
    d)
      SKIP_BREW_DRIVERS=1
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

# Step: Essentials
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

# Step: Install brew apps
if ! (( SKIP_BREW )) then
  while IFS= read -u 9 -r line; do
    brew_install $line
  done 9< "list/brew_programs.txt"
else
  log_b "Skipping brew programs installation on request..."
fi


# Step: Install NVM
ff ! (( SKIP_NVM )) then
  # Install NVM (if it is not already installed)
  if ! type nvm; then
    log_e "Installing NVM..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh)"
  else
    log_e "NVM already seems to be installed. Skipping..."
  fi
fi

# Step: Install brew cask apps
if ! (( SKIP_BREW_CASK )) then
  # Install from cask list
  while IFS= read -u 9 -r line; do
    if (( ASK_BREW_CASK )) then
        read -p "Do you want to install $line (y/n)?" choice
        case "$choice" in
            y|Y ) brew_cask_install $line;;
            n|N ) ;;
            * ) log_c "Invalid choice. We will not install $line.";;
        esac
    else
        brew_cask_install $line
    fi
  done 9< "list/brew_cask_programs.txt"
else
  log_c "Skipping brew cask programs installation on request..."
fi

# Step: Install brew drivers
if ! (( SKIP_BREW_DRIVERS )) then
  # Tap driver cask
  brew tap homebrew/cask-drivers

  # Install from cask list
  while IFS= read -u 9 -r line; do
    brew_driver_install $line
  done 9< "list/brew_driver_programs.txt"
else
  log_d "Skipping brew driver programs installation on request..."
fi

# Step: Install MAS apps
if ! (( SKIP_MAS )) then
  # Warning about mas
  log_m "Starting installation of apps from the Mac App Store..."
  log_m "WARNING: If this is your first time downloading these apps, installation will fail because there will be no purchase history."
  log_m "It is therefore recommended that you first download the apps through the App Store."
  log_m "Subsequent script runs will automatically find and download those apps from your purchase history."

  # Install mas apps
  while IFS= read -u 9 -r line; do
    mas_install $(echo $line | tr -d '\n')
  done 9< "list/mas_programs.txt"

  # Warn about background mas
  log_m "Background app installation started!"
  log_m "WARNING: mas is still installing apps in the background."
  log_m "To see running processes, run ps."
  log_m "To see download progress, go to the Launchpad."
  log_m "It is recommended that you do not restart the computer while the commands are running."
else
  log_m "Skipping Mac App Store programs installation on request..."
fi

