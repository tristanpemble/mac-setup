#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE=$(tput setaf 7)
RESET="$(tput sgr0)"
BOLD="$(tput bold)"

banner ()
{
  echo "$GREEN$BOLD"
  echo "================================================================================"
  echo "= $WHITE$1$GREEN"
  echo "================================================================================"
  echo "$RESET"
}

# Ask for the administrator password upfront
sudo -v -p "SUDO Password: "

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

banner "Installing XCode command line tools"

if xcode-select -p > /dev/null 2>&1
then
  echo "Already installed."
else
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress;
  PROD=$(softwareupdate -l |
    grep "\*.*Command Line" |
    head -n 1 | awk -F"*" '{print $2}' |
    sed -e 's/^ *//' |
    tr -d '\n')
  softwareupdate -i "$PROD";
fi

banner "Installing Homebrew"

if which brew > /dev/null 2>&1
then
  echo "Already installed."
else
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null
fi

banner "Cloning (or updating) the repository"

if ! grep tristanpemble/mac-setup .git/config > /dev/null 2>&1
then
  if [ -d ~/.mac-setup ]
  then
    cd ~/.mac-setup
    git pull
  else
    git clone https://github.com/tristanpemble/mac-setup ~/.mac-setup
    cd ~/.mac-setup
  fi
else
  echo "Already in repository root."
fi

banner "Installing applications and packages"

brew update
if which xcodebuild
then
  sudo xcodebuild -license accept
  brew update && brew bundle
else
  brew update && brew bundle
  sudo xcodebuild -license accept
fi

banner "Installing Node.JS utilities"
yarn global add \
  bower \
  create-react-app \
  ember-cli \
  grunt-cli \
  gulp-cli

banner "Configuring the system"
bash ./config.sh

banner "All done!"

echo "Rebooting the system in.. (ctrl+c to exit)"
for i in {5..1}
do
  echo "${i}.."
  sleep 1
done

sudo shutdown -r now
