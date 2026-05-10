# Dotfiles

Personal dotfiles managed with GNU Stow. The setup script is primarily for macOS systems, but it supports macOS and best-effort Linux installs.

## Setup

```sh
/bin/bash ~/dotfiles/setup.sh
```

The setup script installs common dependencies, creates private local secret files, bootstraps external plugin repos, checks for remote dotfiles updates, and stows the packages in this repo into `$HOME`.

On macOS, dependencies are installed with Homebrew. On Linux, the script uses `apt`, `dnf`, or `pacman` when sudo/admin access is available and warns for tools that are not available from the detected package manager.

On no-admin Linux environments, including HPC systems such as Rocky Linux clusters, the script checks for Environment Modules and installs as many CLI tools as possible into `$HOME/.local`, `$HOME/.cargo`, and `$HOME/go` using user-level installers.

Force no-admin mode even when `sudo` exists:

```sh
DOTFILES_NO_SUDO=1 ./setup.sh
```

If your cluster provides tools as modules, add persistent module loads to `~/.config/secrets/shell.env`, for example:

```sh
module load git
module load neovim
module load tmux
module load python
module load nodejs
module load go
```

External repos such as TPM and `fzf-git.sh` are cloned into local directories before Stow runs so generated/vendor files stay out of the dotfiles repo.

## Manual Stow

From `~/dotfiles`:

```sh
stow -R -t ~ aerospace ghostty hyper karabiner nvim scripts tmux yazi zsh
```

On Linux, macOS-only packages such as `aerospace` and `karabiner` are skipped by `setup.sh`. Manual Linux Stow command:

```sh
stow -R -t ~ ghostty hyper nvim scripts tmux yazi zsh
```

## Updates

`setup.sh` fetches the configured Git remotes for this repo and warns when the local branch is behind its upstream. To update manually:

```sh
cd ~/dotfiles
git pull --ff-only
./setup.sh
```

To apply only symlink changes after pulling:

```sh
cd ~/dotfiles
stow -R -t "$HOME" aerospace ghostty hyper karabiner nvim scripts tmux yazi zsh
```

On Linux, use:

```sh
stow -R -t "$HOME" ghostty hyper nvim scripts tmux yazi zsh
```

## Secrets

Secrets are intentionally kept outside this repo. The default location for secrets is:

```sh
~/.config/secrets/shell.env
```

`.zshrc` sources that file when it exists.

Optional Aerospace monitor overrides live in:

```sh
~/.config/secrets/aerospace.env
```

Use it to pin role-based workspace placement for `TERMINAL_MONITOR`, `BROWSER_MONITOR`, and `CHAT_MONITOR` without committing machine-specific monitor names or IDs.

## Local Overrides

The tmux sessionizer searches `${DOTFILES_DIR:-$HOME/dotfiles}`, `$HOME/Desktop`, and `$HOME` by default. Override the roots with a colon-separated value in `~/.config/secrets/shell.env`:

```sh
export TMUX_SESSIONIZER_DIRS="$HOME/dotfiles:$HOME/Projects:$HOME/work"
```

The Neovim dashboard logo lives at `assets/logo.png` in this repo. Replace that file to customize it.

Add extra global image search directories for Neovim with:

```sh
export NVIM_IMAGE_DIRS="$HOME/Downloads:$HOME/Library"
```
