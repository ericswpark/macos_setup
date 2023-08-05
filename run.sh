#!/bin/zsh

# If any part of this script fails, exit immediately
set -e

# Initialize variables
local -i SHOW_HELP=0
local -i SKIP_ESSENTIALS=0
local -i SKIP_BREW=0
local -i SKIP_OH_MY_ZSH=0
local -i SKIP_NVM=0

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
  -o        Skip Oh My Zsh installation
  -n        Skip NVM (Node Version Manager) installation
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

# FUNCTION: Oh My Zsh logger
# Usage log_o <log>
function log_o {
    log "OHMYZSH" $1
}

# FUNCTION: NVM logger
# Usage log_n <log>
function log_n {
    log "NVM" $1
}


# --------
# | MAIN |
# --------

# Check for flags
while getopts "h?ebon" option
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
    o)
      SKIP_OH_MY_ZSH=1
      ;;
    n)
      SKIP_NVM=1
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

# Step: Restore with brew bundle
if ! (( SKIP_BREW )) then
  log_b "Restoring from Homebrew bundle dump..."
  brew bundle install --file ./Brewfile
else
  log_b "Skipping brew programs installation on request..."
fi

# Step: Install Oh My Zsh
if ! (( SKIP_OH_MY_ZSH )) then
  # Install Oh My Zsh (if it is not already installed)
  if [[ ! -d ~/.oh-my-zsh ]]; then
    log_o "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    log_o "Oh My Zsh already seems to be installed. Skipping..."
  fi
fi

# Step: Install NVM
if ! (( SKIP_NVM )) then
  # Install NVM (if it is not already installed)
  if ! type nvm; then
    log_n "Installing NVM..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh)"
  else
    log_n "NVM already seems to be installed. Skipping..."
  fi
fi
