# macos_setup

## Usage

    Usage:      ./run.sh     <flags>

    Purpose:    Completely set up a fresh macOS install with specified tools

    -h        Show usage (this output)
    -e        Skip essential installs and SSH key generation
                Only use this flag if your SSH key is not named id_rsa and you
                wish to skip automatic detection of your SSH key. If brew is not
                installed, the rest of the modules will fail.
    -b        Skip brew app installation
    -m        Skip mas app installation


## Adding App Store apps

    mas search Word

Add to `list/mas_programs.txt`:

    462054704 "Microsoft Word"

## `mas` won't install apps

Make sure you have the app in your purchase history. `mas` won't install apps you don't own.
