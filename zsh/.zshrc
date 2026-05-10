# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export ZSH="$HOME/.oh-my-zsh"

# zsh theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh plugins
plugins=(git)

source $ZSH/oh-my-zsh.sh

# editor
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# aliases
alias c="clear"
alias e="exit"

alias cat="bat"
alias cd="z"
alias ls="eza --no-filesize --long --color=always --icons=always --no-user"
alias npm="bun"
alias npx="bunx"

alias zshconfig="$EDITOR ~/.zshrc"
alias nlof="fzf_listoldfiles.sh"
alias fman="compgen -c | fzf | xargs man"
alias nzo="zoxide_openfiles_nvim.sh"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Android SDK setup
if [[ -x /usr/libexec/java_home ]]; then
  java_home_17="$(/usr/libexec/java_home -v 17 2>/dev/null)"
  [[ -n "$java_home_17" ]] && export JAVA_HOME="$java_home_17"
fi
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Python setup
if command -v brew >/dev/null 2>&1; then
  homebrew_prefix="$(brew --prefix)"

  if python_prefix="$(brew --prefix python@3.12 2>/dev/null)"; then
    export PATH="$python_prefix/libexec/bin:$PATH"
  fi
fi

# Custom scripts setup
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$GOPATH/bin:$PATH"
export PATH="$PATH:$HOME/scripts"

# openSSL setup for C++
if command -v brew >/dev/null 2>&1 && openssl_prefix="$(brew --prefix openssl@3 2>/dev/null)"; then
  export PATH="$openssl_prefix/bin:$PATH"
  export LDFLAGS="-L$openssl_prefix/lib"
  export CPPFLAGS="-L$openssl_prefix/include"
  export PKG_CONFIG_PATH="$openssl_prefix/lib/pkgconfig"
fi

# console-ninja
export PATH="$HOME/.console-ninja/.bin:$PATH"

# bun
export PATH="$HOME/.bun/bin:$PATH"

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Local secrets, kept outside the dotfiles repo.
if [[ -f "$HOME/.config/secrets/shell.env" ]]; then
  source "$HOME/.config/secrets/shell.env"
fi

# this function runs on every directory change
chpwd() {
    if [[ -f .nvmrc ]]; then
        nvm use
    fi
}

# zoxide
eval "$(zoxide init zsh)"

# fzf
eval "$(fzf --zsh)"
export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"
export FZF_DEFAULT_OPTS="--height 50% --layout=default --border
--color=hl:#2dd4bf"
export FZF_TMUX_OPTS=" -p90%,70% "
export FZF_CTRL_T_OPTS="--preview 'bat --color=always -n --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# from https://github.com/junegunn/fzf-git.sh
if [[ -f "$HOME/scripts/fzf-git.sh" ]]; then
  source "$HOME/scripts/fzf-git.sh"
fi

_fzf_compgen_path() {
    fd --type=f --hidden --exclude .git "$1"
}

_fzf_compgen_dir() {
    fd --type=d --hidden --exclude .git "$1"
}

_fzf_comprun() {
    local command=$1
}

# zsh plugins
if [[ -n ${homebrew_prefix:-} ]]; then
  [[ -f "$homebrew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$homebrew_prefix/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [[ -f "$homebrew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$homebrew_prefix/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

[[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
