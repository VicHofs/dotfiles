#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
DOTFILES_OSI_ONLY=0
OS="$(uname -s)"

log() {
  printf '\n==> %s\n' "$1"
}

has() {
  command -v "$1" >/dev/null 2>&1
}

warn() {
  printf 'WARN: %s\n' "$1" >&2
}

usage() {
  cat <<'EOF'
Usage: setup.sh [--osi]

Options:
  --osi      Skip packages that are not distributed under OSI-approved licenses.
  --no-sudo  Do not try to use sudo; install only user-local tools where possible.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --osi)
        DOTFILES_OSI_ONLY=1
        ;;
      --no-sudo)
        DOTFILES_NO_SUDO=1
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        usage >&2
        exit 2
        ;;
    esac
    shift
  done
}

is_non_osi_package() {
  # Proprietary apps and Google SDK terms are not OSI-approved licenses.
  case "$1" in
    android-platform-tools|obsidian|raycast|shortcat)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

filter_osi_packages() {
  local package

  for package in "$@"; do
    if is_non_osi_package "$package"; then
      printf 'Skipping non-OSI package: %s\n' "$package" >&2
      continue
    fi

    printf '%s\n' "$package"
  done
}

can_sudo() {
  if [[ ${DOTFILES_NO_SUDO:-0} == 1 ]]; then
    return 1
  fi

  if ! has sudo; then
    return 1
  fi

  sudo -n true >/dev/null 2>&1 || { [[ -t 0 ]] && sudo -v >/dev/null 2>&1; }
}

ensure_local_bin() {
  mkdir -p "$HOME/.local/bin" "$HOME/.local/opt"
  export PATH="$HOME/.local/bin:$PATH"
}

install_brew_formulae() {
  local package

  log "Installing Homebrew formulae"
  for package in "$@"; do
    if brew list --formula "$package" >/dev/null 2>&1; then
      printf 'Already installed: %s\n' "$package"
      continue
    fi

    if ! brew install "$package"; then
      warn "Could not install Homebrew formula: $package"
    fi
  done
}

install_brew_casks() {
  local package

  log "Installing Homebrew casks"
  for package in "$@"; do
    if brew list --cask "$package" >/dev/null 2>&1; then
      printf 'Already installed: %s\n' "$package"
      continue
    fi

    if ! brew install --cask "$package"; then
      warn "Could not install Homebrew cask: $package"
    fi
  done
}

install_apt_packages() {
  local package

  log "Installing apt packages"
  sudo apt-get update || warn "apt-get update failed; continuing with package installs"

  for package in "$@"; do
    if ! sudo apt-get install -y "$package"; then
      warn "Could not install apt package: $package"
    fi
  done
}

install_dnf_packages() {
  local package

  log "Installing dnf packages"
  for package in "$@"; do
    if ! sudo dnf install -y "$package"; then
      warn "Could not install dnf package: $package"
    fi
  done
}

install_pacman_packages() {
  local package

  log "Installing pacman packages"
  sudo pacman -Syu --noconfirm || warn "pacman system update failed; continuing with package installs"

  for package in "$@"; do
    if ! sudo pacman -S --needed --noconfirm "$package"; then
      warn "Could not install pacman package: $package"
    fi
  done
}

install_homebrew() {
  if has brew; then
    log "Homebrew already installed"
    return
  fi

  log "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_xcode_tools() {
  if [[ "$OS" != "Darwin" ]]; then
    return
  fi

  if xcode-select -p >/dev/null 2>&1; then
    log "Xcode command line tools already installed"
    return
  fi

  log "Installing Xcode command line tools"
  xcode-select --install
  printf 'Complete the GUI installer, then rerun this script.\n'
  exit 0
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log "Oh My Zsh already installed"
    return
  fi

  if ! has curl; then
    warn "curl is not available; skipping Oh My Zsh install."
    return
  fi

  log "Installing Oh My Zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || warn "Could not install Oh My Zsh"
}

install_powerlevel10k() {
  local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

  if [[ -d "$theme_dir" ]]; then
    log "Powerlevel10k already installed"
    return
  fi

  if ! has git; then
    warn "git is not available; skipping Powerlevel10k install."
    return
  fi

  log "Installing Powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir" || warn "Could not install Powerlevel10k"
}

install_brew_packages() {
  local casks formulae package

  log "Updating Homebrew"
  brew analytics off >/dev/null 2>&1 || true
  brew update

  log "Adding Homebrew taps"
  brew tap homebrew/cask-fonts || true
  brew tap thezoraiz/ascii-image-converter || true
  brew tap joshmedeski/sesh || true
  brew tap nikitabobko/tap || true
  brew tap anomalyco/tap || true
  brew tap theboredteam/boring-notch || true
  brew tap stonerl/thaw || true

  formulae=(
    thezoraiz/ascii-image-converter/ascii-image-converter
    android-platform-tools
    bat
    bun
    chafa
    coreutils
    eza
    fd
    ffmpeg
    fzf
    git
    gum
    imagemagick
    jq
    lazygit
    neovim
    nvm
    openssl@3
    anomalyco/tap/opencode
    pngpaste
    poppler
    python@3.12
    resvg
    ripgrep
    rmpc
    joshmedeski/sesh/sesh
    sevenzip
    stow
    tmux
    tree
    tree-sitter
    thaw
    yazi
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
  )

  if [[ "$DOTFILES_OSI_ONLY" == 1 ]]; then
    local osi_formulae=()
    while IFS= read -r package; do
      osi_formulae+=("$package")
    done < <(filter_osi_packages "${formulae[@]}")
    formulae=("${osi_formulae[@]}")
  fi

  install_brew_formulae "${formulae[@]}"

  casks=(
    nikitabobko/tap/aerospace
    theboredteam/boring-notch/boring-notch
    ghostty
    karabiner-elements
    raycast
    shortcat
    stats
    obsidian
    temurin@17
    font-fira-code-nerd-font
    font-hack-nerd-font
    font-meslo-lg-nerd-font
  )

  if [[ "$DOTFILES_OSI_ONLY" == 1 ]]; then
    local osi_casks=()
    while IFS= read -r package; do
      osi_casks+=("$package")
    done < <(filter_osi_packages "${casks[@]}")
    casks=("${osi_casks[@]}")
  fi

  install_brew_casks "${casks[@]}"
}

install_linux_packages() {
  local common=(
    bat
    curl
    eza
    fd-find
    fzf
    git
    golang-go
    gum
    imagemagick
    jq
    lazygit
    neovim
    npm
    openssl
    pngpaste
    python3
    python3-pip
    ripgrep
    stow
    tmux
    tree
    tree-sitter-cli
    yazi
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  )

  local dnf_common=(
    bat
    curl
    eza
    fd-find
    fzf
    git
    golang
    gum
    ImageMagick
    jq
    lazygit
    neovim
    npm
    openssl
    python3
    python3-pip
    ripgrep
    stow
    tmux
    tree
    tree-sitter-cli
    yazi
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  )

  local pacman_common=(
    bat
    curl
    eza
    fd
    fzf
    git
    go
    imagemagick
    jq
    lazygit
    neovim
    npm
    openssl
    python
    python-pip
    ripgrep
    stow
    tmux
    tree
    tree-sitter
    yazi
    zoxide
    zsh
    zsh-autosuggestions
    zsh-syntax-highlighting
  )

  if ! can_sudo; then
    warn "No passwordless sudo/admin access detected; skipping system package manager installs."
    setup_environment_modules
    install_user_local_tools
    ensure_linux_command_shims
    install_linux_optional_tools
    return
  fi

  if has apt-get; then
    install_apt_packages "${common[@]}" || warn "Some apt packages could not be installed"
  elif has dnf; then
    install_dnf_packages "${dnf_common[@]}" || warn "Some dnf packages could not be installed"
  elif has pacman; then
    install_pacman_packages "${pacman_common[@]}" || warn "Some pacman packages could not be installed"
  else
    warn "No supported Linux package manager found. Install dependencies manually."
    return
  fi

  ensure_linux_command_shims
  install_linux_optional_tools
}

setup_environment_modules() {
  if [[ "$OS" != "Linux" ]]; then
    return
  fi

  if ! type module >/dev/null 2>&1; then
    [[ -r /etc/profile.d/modules.sh ]] && . /etc/profile.d/modules.sh
    [[ -r /usr/share/Modules/init/bash ]] && . /usr/share/Modules/init/bash
  fi

  if ! type module >/dev/null 2>&1; then
    warn "Environment Modules are not available in this shell. If your HPC uses modules, run 'module avail' manually."
    return
  fi

  log "Checking HPC environment modules"
  printf 'Environment Modules detected. Available useful modules may include git, neovim, tmux, python, node, go, gcc, rust, ripgrep, fzf, or java.\n'
  printf 'Module loads inside setup only affect this process. For persistent use, add module loads to ~/.config/secrets/shell.env.\n'

  try_load_module git Git
  try_load_module neovim nvim
  try_load_module tmux
  try_load_module python python3
  try_load_module node nodejs
  try_load_module go golang
  try_load_module rust cargo
  try_load_module java openjdk
}

try_load_module() {
  local candidate

  if ! type module >/dev/null 2>&1; then
    return
  fi

  for candidate in "$@"; do
    if module -t avail "$candidate" >/dev/null 2>&1; then
      module load "$candidate" >/dev/null 2>&1 && printf 'Loaded module: %s\n' "$candidate" && return
    fi
  done
}

install_user_local_tools() {
  log "Installing user-local tools where possible"
  ensure_local_bin

  install_user_neovim
  install_user_stow
  install_user_fzf
  install_user_rustup
  install_user_cargo_tools
  install_user_go_tools
  install_user_npm_tools
}

install_user_neovim() {
  local archive install_dir

  if has nvim || [[ "$OS" != "Linux" ]] || [[ "$(uname -m)" != "x86_64" ]] || ! has curl || ! has tar; then
    return
  fi

  log "Installing Neovim to ~/.local"
  archive="$HOME/.local/opt/nvim-linux-x86_64.tar.gz"
  install_dir="$HOME/.local/opt/nvim-linux-x86_64"

  if curl -fL --retry 3 -o "$archive" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz; then
    rm -rf "$install_dir"
    tar -xzf "$archive" -C "$HOME/.local/opt"
    ln -sf "$install_dir/bin/nvim" "$HOME/.local/bin/nvim"
  else
    warn "Could not install user-local Neovim"
  fi
}

install_user_stow() {
  local archive source_dir version

  if has stow || ! has curl || ! has tar || ! has make || ! has perl; then
    return
  fi

  version="2.4.1"
  archive="$HOME/.local/opt/stow-$version.tar.gz"
  source_dir="$HOME/.local/opt/stow-$version"

  log "Installing GNU Stow to ~/.local"
  if curl -fL --retry 3 -o "$archive" "https://ftp.gnu.org/gnu/stow/stow-$version.tar.gz"; then
    rm -rf "$source_dir"
    tar -xzf "$archive" -C "$HOME/.local/opt"
    (cd "$source_dir" && ./configure --prefix="$HOME/.local" && make install) || warn "Could not install user-local GNU Stow"
  else
    warn "Could not download GNU Stow"
  fi
}

install_user_fzf() {
  local fzf_dir="$HOME/.local/opt/fzf"

  if has fzf || ! has git; then
    return
  fi

  log "Installing fzf to ~/.local"
  if [[ ! -d "$fzf_dir" ]]; then
    git clone --depth=1 https://github.com/junegunn/fzf.git "$fzf_dir" || { warn "Could not clone fzf"; return; }
  fi

  "$fzf_dir/install" --bin --no-update-rc >/dev/null 2>&1 || warn "Could not install fzf binary"
  [[ -x "$fzf_dir/bin/fzf" ]] && ln -sf "$fzf_dir/bin/fzf" "$HOME/.local/bin/fzf"
}

install_user_rustup() {
  if has cargo || ! has curl; then
    return
  fi

  log "Installing Rust toolchain to ~/.cargo"
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path || warn "Could not install rustup"
  [[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
}

install_user_cargo_tools() {
  if ! has cargo; then
    warn "cargo is not available; skipping user-local Rust CLI installs."
    return
  fi

  export PATH="$HOME/.cargo/bin:$PATH"
  cargo_install_if_missing bat bat
  cargo_install_if_missing eza eza
  cargo_install_if_missing fd fd-find
  cargo_install_if_missing rg ripgrep
  cargo_install_if_missing zoxide zoxide
  cargo_install_if_missing yazi yazi-fm
  cargo_install_if_missing rmpc rmpc
}

cargo_install_if_missing() {
  local command_name="$1"
  local crate_name="$2"

  if has "$command_name"; then
    return
  fi

  log "Installing $command_name with cargo"
  cargo install --locked "$crate_name" || warn "Could not install cargo crate: $crate_name"
}

install_user_go_tools() {
  if ! has go; then
    warn "go is not available; skipping user-local Go CLI installs."
    return
  fi

  export GOPATH="${GOPATH:-$HOME/go}"
  export PATH="$GOPATH/bin:$PATH"
  go_install_if_missing lazygit github.com/jesseduffield/lazygit@latest
  go_install_if_missing gum github.com/charmbracelet/gum@latest
  go_install_if_missing sesh github.com/joshmedeski/sesh@latest
  go_install_if_missing ascii-image-converter github.com/TheZoraiz/ascii-image-converter@latest
}

go_install_if_missing() {
  local command_name="$1"
  local package_name="$2"

  if has "$command_name"; then
    return
  fi

  log "Installing $command_name with go"
  go install "$package_name" || warn "Could not install Go package: $package_name"
}

install_user_npm_tools() {
  if ! has npm; then
    warn "npm is not available; skipping user-local npm CLI installs."
    return
  fi

  npm config set prefix "$HOME/.local" >/dev/null 2>&1 || true
  export PATH="$HOME/.local/bin:$PATH"
  npm_install_if_missing opencode opencode-ai
  npm_install_if_missing tree-sitter tree-sitter-cli
}

npm_install_if_missing() {
  local command_name="$1"
  local package_name="$2"

  if has "$command_name"; then
    return
  fi

  log "Installing $command_name with npm"
  npm install -g "$package_name" || warn "Could not install npm package: $package_name"
}

ensure_linux_command_shims() {
  if [[ "$OS" != "Linux" ]]; then
    return
  fi

  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"

  if ! has bat && has batcat; then
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
  fi

  if ! has fd && has fdfind; then
    ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
  fi
}

install_linux_optional_tools() {
  if ! has bun && has curl; then
    log "Installing Bun"
    curl -fsSL https://bun.sh/install | bash || warn "Could not install Bun"
  fi

  if ! has lazygit && has go; then
    log "Installing lazygit with go"
    go install github.com/jesseduffield/lazygit@latest || warn "Could not install lazygit"
  elif ! has lazygit; then
    warn "lazygit is not installed. Install it manually or install Go and rerun setup."
  fi

  if ! has eza; then
    warn "eza is not installed. It may not be available from this platform's default package repositories."
  fi

  if ! has yazi; then
    warn "yazi is not installed. It may not be available from this platform's default package repositories."
  fi

  if ! has sesh; then
    warn "sesh is not installed. Tmux session bindings that use sesh will not work until it is installed."
  fi

  if ! has rmpc; then
    warn "rmpc is not installed. The tmux music popup binding will not work until it is installed."
  fi

  if ! has ascii-image-converter; then
    warn "ascii-image-converter is not installed. The Neovim dashboard image section will be skipped/fail until it is installed."
  fi
}

install_platform_packages() {
  case "$OS" in
    Darwin)
      install_xcode_tools
      install_homebrew
      install_brew_packages
      ;;
    Linux)
      install_linux_packages
      ;;
    *)
      warn "Unsupported platform: $OS. Skipping package installation."
      ;;
  esac
}

check_dotfiles_updates() {
  local branch upstream counts ahead behind

  if ! has git; then
    warn "git is not installed; skipping dotfiles update check."
    return
  fi

  if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
    warn "$DOTFILES_DIR is not a Git repository; skipping dotfiles update check."
    return
  fi

  log "Checking dotfiles remote for updates"

  if ! git -C "$DOTFILES_DIR" fetch --quiet --all --prune; then
    warn "Could not fetch dotfiles remotes; skipping update comparison."
    return
  fi

  branch="$(git -C "$DOTFILES_DIR" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"
  if [[ -z "$branch" ]]; then
    warn "Dotfiles repo is in detached HEAD; skipping update comparison."
    return
  fi

  upstream="$(git -C "$DOTFILES_DIR" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"
  if [[ -z "$upstream" ]] && git -C "$DOTFILES_DIR" show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    upstream="origin/$branch"
  fi

  if [[ -z "$upstream" ]]; then
    warn "No upstream remote branch found for $branch; skipping update comparison."
    return
  fi

  if ! counts="$(git -C "$DOTFILES_DIR" rev-list --left-right --count "HEAD...$upstream")"; then
    warn "Could not compare HEAD with $upstream; skipping update comparison."
    return
  fi

  read -r ahead behind <<< "$counts"

  if [[ "$behind" != "0" ]]; then
    warn "Dotfiles repo is $behind commit(s) behind $upstream."
    printf '\nUpdate instructions:\n'
    printf '  cd %q\n' "$DOTFILES_DIR"
    printf '  git pull --ff-only\n'
    printf '  DOTFILES_DIR=%q ./setup.sh\n' "$DOTFILES_DIR"
    printf '\nTo apply only symlink changes after pulling:\n'
    printf '  cd %q\n' "$DOTFILES_DIR"
    printf '  stow -R -t "$HOME" %s\n' "$(stow_packages)"
  elif [[ "$ahead" != "0" ]]; then
    printf 'Dotfiles repo is up to date with %s and %s commit(s) ahead locally.\n' "$upstream" "$ahead"
  else
    printf 'Dotfiles repo is up to date with %s.\n' "$upstream"
  fi
}

stow_packages() {
  case "$OS" in
    Darwin)
      printf '%s\n' aerospace ghostty hyper karabiner nvim scripts tmux yazi zsh
      ;;
    Linux)
      printf '%s\n' ghostty hyper nvim scripts tmux yazi zsh
      ;;
    *)
      printf '%s\n' nvim scripts tmux yazi zsh
      ;;
  esac
}

bootstrap_repos() {
  log "Bootstrapping external plugin repos"

  if ! has git; then
    warn "git is not available; skipping external plugin repo bootstrap."
    return
  fi

  mkdir -p "$HOME/.config/tmux/.tmux/plugins"
  mkdir -p "$HOME/scripts"

  if [[ ! -d "$HOME/.config/tmux/.tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/.tmux/plugins/tpm" || warn "Could not clone TPM"
  fi

  if [[ ! -d "$HOME/scripts/fzf-git.sh" ]]; then
    git clone https://github.com/junegunn/fzf-git.sh "$HOME/scripts/fzf-git.sh" || warn "Could not clone fzf-git.sh"
  fi
}

install_tmux_plugins() {
  local install_script plugin_dir

  if ! has tmux; then
    warn "tmux is not installed; skipping tmux plugin install."
    return
  fi

  plugin_dir="$HOME/.config/tmux/.tmux/plugins"
  install_script="$plugin_dir/tpm/bin/install_plugins"

  if [[ ! -x "$install_script" ]]; then
    warn "TPM installer is not available; skipping tmux plugin install."
    return
  fi

  log "Installing tmux plugins"
  tmux start-server \; set-environment -g TMUX_PLUGIN_MANAGER_PATH "$plugin_dir" || warn "Could not configure TPM plugin path"
  TMUX_PLUGIN_MANAGER_PATH="$plugin_dir" "$install_script" || warn "Could not install tmux plugins"
}

ensure_private_files() {
  log "Ensuring private local files exist"
  mkdir -p "$HOME/.config/secrets"
  chmod 700 "$HOME/.config/secrets"

  if [[ ! -f "$HOME/.config/secrets/shell.env" ]]; then
    cat >"$HOME/.config/secrets/shell.env" <<'EOF'
# Private shell environment. Do not commit this file.
EOF
    chmod 600 "$HOME/.config/secrets/shell.env"
  fi

  if [[ ! -f "$HOME/.config/secrets/aerospace.env" ]]; then
    cat >"$HOME/.config/secrets/aerospace.env" <<'EOF'
# Optional local Aerospace monitor overrides. Do not commit this file.
# Use monitor IDs or names from: aerospace list-monitors --format '%{monitor-id} %{monitor-name}'
# TERMINAL_MONITOR="1"
# BROWSER_MONITOR="2"
# CHAT_MONITOR="3"
EOF
    chmod 600 "$HOME/.config/secrets/aerospace.env"
  fi
}

stow_dotfiles() {
  local packages

  if ! has stow; then
    warn "GNU Stow is not installed; skipping dotfile symlinks."
    return
  fi

  log "Stowing dotfiles"
  cd "$DOTFILES_DIR"

  mkdir -p "$HOME/.config"
  packages="$(stow_packages)"

  # shellcheck disable=SC2086
  stow -R -t "$HOME" $packages
}

main() {
  parse_args "$@"

  install_platform_packages
  install_oh_my_zsh
  install_powerlevel10k
  ensure_private_files
  bootstrap_repos
  check_dotfiles_updates
  stow_dotfiles
  install_tmux_plugins

  log "Setup complete"
}

main "$@"
