# macos_setup

## What does this script do?

If you just run the script (`./run.sh`) without any parameters suppplied, it will:

- Install [Homebrew](https://brew.sh) on your system
- Make sure you have an SSH key (and will generate one if you don't)
- Restore the Homebrew installation from the `Brewfile`. (Supply your own if you want!)
- Install [NVM](https://github.com/nvm-sh/nvm) for managing NodeJS versions

## Usage

As the usage below may be out of date, run `./run.sh -h` to see available options.

```
Usage:      ./run.sh    <flags>

Purpose:    Completely set up a fresh macOS install with specified tools

  -h        Show usage (this output) and quit immediately
  -e        Skip essential installs and SSH key generation
            Only use this flag if your SSH key is not named id_rsa and you
            wish to skip automatic detection of your SSH key. If brew is not
            installed, the rest of the modules will fail.
  -b        Skip brew app installation
  -n        Skip NVM (Node Version Manager) installation
```

## `mas` won't install apps

Make sure you have the app in your purchase history. `mas` won't install apps you don't own.
