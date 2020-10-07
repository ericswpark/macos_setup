# macos_setup

## Usage

    Usage:      ./init-macos.sh     <flags>

    Purpose:    Completely set up a fresh macOS install with specified tools

    -h        Show usage (this output)
    -e        Skip essential installs and SSH key generation
                It is not recommended to use this flag since the script will
                automatically check if brew is installed and if the SSH key already
                exists. If they do, then the script will skip installation and
                generation.
    -b        Skip brew app installation
    -c        Skip brew cask app installation
    -m        Skip mas app installation


## Adding App Store apps

    mas search Word

Add to `list/mas_programs.txt`:

    462054704 "Microsoft Word"

## `mas` won't install apps

Make sure you have the app in your purchase history. `mas` won't install apps you don't own.
