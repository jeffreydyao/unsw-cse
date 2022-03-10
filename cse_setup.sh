#!/bin/sh/
# Sets up SSHFS to mount and access your CSE filesystem
# locally, and terminal shortcuts for doing so using Fig.
# Works on macOS only.
# Credits: https://abiram.me/cse-sshfs
# Written by Jeffrey Yao (@jeffreydyao on GitHub)
############################################################

# Define bold and italic
bold=$(tput bold)
normal=$(tput sgr0)

cd ~

# Check to see if Homebrew is installed, and install if not
which -s brew
if [[ $? != 0 ]] ; then
    # Install Homebrew
    echo "🔮 ${bold}Installing Homebrew${bold}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add Homebrew installation location to path
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ${HOME}/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    # Update Homebrew
    brew update
fi

# Install MacFUSE
echo "🔮 ${bold}Installing MacFUSE${bold}"
brew install --cask macfuse

# Install SSHFS
echo "🔮 ${bold}Installing SSHFS${bold}"
brew install gromgit/fuse/sshfs-mac

# Install Fig
echo "🔮 ${bold}Installing Fig${bold}"
brew install --cask fig

# Check if dependencies present to create Fig autocomplete spec
which -s npm
if [[ $? != 0 ]] ; then
    # Install Node.js
    echo "🔮 ${bold}Installing Node.js and npm${bold}"
    brew install node
fi

# Create Fig autocomplete spec
npx -s @withfig/autocomplete-tools@latest init
cd .fig/autocomplete
npm run create-spec +
cd src

# Set shortcuts up using student zID
cat <<EOF
🔮 ${bold}Let's set up your shortcuts! What's your zID? (Enter in format z1234567)${bold}
EOF
read student_number

cat <<EOF > +.ts
const completionSpec: Fig.Spec = {
  name: "+",
  description: "UNSW CSE shortcuts",
  subcommands: [
    {
      icon: "🔌",
      name: "Connect to UNSW CSE",
      insertValue: "\b\bsshfs -o idmap=user -C $student_number@login${student_number: -1}.cse.unsw.edu.au: ~/cse\n",
      description: "Mount CSE home directory as network drive.",
    },
    {
      icon: "⌨️",
      name: "Open VS Code in CSE folder",
      insertValue: "\b\bcode ~/cse\n",
      description: "Open a new VS Code session in your CSE folder.",
    },
    {
      icon: "🖥",
      name: "Open CSE shell",
      insertValue: "\b\bssh $student_number@login${student_number: -1}.cse.unsw.edu.au\n",
      description: "Start a shell session on your CSE machine.",
    },
    {
      icon: "💢",
      name: "Disconnect from UNSW CSE",
      insertValue: "\b\bumount -f ~/cse\n",
      description: "Unmount CSE network drive.",
    },
  ],
};
export default completionSpec;
EOF

# Compile autocomplete spec
npm run --silent build

# Set shortcut trigger to +
fig settings autocomplete.personalShortcutsToken +

# Open Fig
open /Applications/Fig.app


# Print success message.
echo "✅ ${bold}Your machine's configured to connect to CSE servers now, with terminal shortcuts!${bold}"
echo "⚠️ After setting Fig up, you must restart for everything to work properly."
echo "💡 In any terminal, enter + then hit space for CSE connection shortcuts. You can add more by following this guide: https://fig.io/docs/guides/personal-shortcuts"