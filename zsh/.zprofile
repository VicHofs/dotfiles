if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

obsidian_bin="/Applications/Obsidian.app/Contents/MacOS"
if [[ -d "$obsidian_bin" ]]; then
  export PATH="$PATH:$obsidian_bin"
fi
