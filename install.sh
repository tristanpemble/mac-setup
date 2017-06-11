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
  softwareupdate -i "$PROD" -v;
fi

banner "Installing Homebrew"

if which brew > /dev/null 2>&1
then
  echo "Already installed."
else
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

banner "Installing Ansible"
brew install ansible

banner "Cloning the repository"

if [ -d "~/.mac-setup" ]
then
  cd ~/.mac-setup
  git pull
else
  git clone https://github.com/tristanpemble/mac-setup ~/.mac-setup
  cd ~/.mac-setup
fi

banner "Installing playbook dependencies"
ansible-galaxy install -r requirements.yml

banner "Configuring the machine with Ansible"
ansible-galaxy install -r requirements.yml
ansible-playbook -K -i inventory ./playbook.yml

banner "All done!"
