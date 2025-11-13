#
# ~/.zshrc
#

# ------------------------------------------------------------------------------
# History file
# ------------------------------------------------------------------------------
  
# Keep the HISTFILE out of git since it is public
HISTFILE=~/projects/run_commands/zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt appendhistory
# setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
# setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
# setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# Explicitly disable history expiration to keep the full history
unsetopt HIST_EXPIRE_DUPS_FIRST
unsetopt HIST_IGNORE_ALL_DUPS

# ------------------------------------------------------------------------------
# Environment
# ------------------------------------------------------------------------------

# direnv fix
# https://github.com/ptavares/zsh-direnv
source ~/.zsh-direnv/zsh-direnv.plugin.zsh

# Export path to root of dotfiles repo
export DOTFILES=${DOTFILES:="$HOME/.dotfiles"}

# Locale
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

# Do not override files using `>`, but it's still possible using `>!`
set -o noclobber

# Extend $PATH without duplicates
_extend_path() {
  [[ -d "$1" ]] || return

  if ! echo "$PATH" | tr ":" "\n" | grep -qx "$1" ; then
    export PATH="$1:$PATH"
  fi
}

# Add custom bin to $PATH
_extend_path "/opt/homebrew/bin" # Add homebrew
_extend_path "$HOME/.local/bin"
_extend_path "$DOTFILES/bin"
_extend_path "$HOME/.npm-global/bin"
_extend_path "$HOME/.rvm/bin"
_extend_path "$HOME/.yarn/bin"
_extend_path "$HOME/.config/yarn/global/node_modules/.bin"
_extend_path "$HOME/.bun/bin"
# https://github.com/rbenv/rbenv
# Needed for ios pod installs
# https://stackoverflow.com/questions/64901180/how-to-run-cocoapods-on-apple-silicon-m1?rq=3
_extend_path "$HOME/.rbenv/bin"
# export PYENV_ROOT="$HOME/.pyenv"
# _extend_path "$PYENV_ROOT/bin"
# Needed for android development
export ANDROID_HOME=$HOME/Library/Android/sdk
_extend_path "$ANDROID_HOME/platform-tools"

_extend_path "/opt/homebrew/opt/mysql@8.4/bin"

# Python from brew https://stackoverflow.com/questions/5157678/how-do-i-use-brew-installed-python-as-the-default-python
_extend_path "/opt/homebrew/opt/python/libexec/bin"

# Pyenv (must be before oh-my-zsh plugin)
# if command -v pyenv >/dev/null 2>&1; then
  # eval "$(pyenv init -)"
# fi

# Extend $NODE_PATH
if [ -d ~/.npm-global ]; then
  export NODE_PATH="$NODE_PATH:$HOME/.npm-global/lib/node_modules"
fi

# Default pager
export PAGER='less'

# less options
less_opts=(
  # Quit if entire file fits on first screen.
  -FX
  # Ignore case in searches that do not contain uppercase.
  --ignore-case
  # Allow ANSI colour escapes, but no other escapes.
  --RAW-CONTROL-CHARS
  # Quiet the terminal bell. (when trying to scroll past the end of the buffer)
  --quiet
  # Do not complain when we are on a dumb terminal.
  --dumb
)
export LESS="${less_opts[*]}"

# Default editor for local and remote sessions
if [[ -n "$SSH_CONNECTION" ]]; then
  # on the server
  if command -v vim >/dev/null 2>&1; then
    export EDITOR='vim'
  else
    export EDITOR='vi'
  fi
else
  export EDITOR='vim'
fi

# Better formatting for time command
export TIMEFMT=$'\n================\nCPU\t%P\nuser\t%*U\nsystem\t%*S\ntotal\t%*E'

# ------------------------------------------------------------------------------
# Oh My Zsh
# ------------------------------------------------------------------------------
export ZSH_DISABLE_COMPFIX=true

# Make it quiet for ssh-agent
zstyle :omz:plugins:ssh-agent quiet yes

# Autoload node version when changing cwd
zstyle ':omz:plugins:nvm' autoload true

# Use passphase from macOS keychain
if [[ "$OSTYPE" == "darwin"* ]]; then
  zstyle :omz:plugins:ssh-agent ssh-add-args --apple-load-keychain >/dev/null 2>&1
fi

# ------------------------------------------------------------------------------
# Dependencies
# ------------------------------------------------------------------------------

# Spaceship project directory (for local development)
SPACESHIP_PROJECT="$HOME/Projects/Repos/spaceship/spaceship-prompt"

# Reset zgen on change
export ZGEN_RESET_ON_CHANGE=(
  "${HOME}/.zshrc"
  "${DOTFILES}"/lib/*.zsh
  "${DOTFILES}"/custom/*.zsh
)
# Load zgen
source "${HOME}/.zgen/zgen.zsh"


# Load zgen init script
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # Oh-My-Zsh plugins
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/history-substring-search
    zgen oh-my-zsh plugins/sudo
    zgen oh-my-zsh plugins/command-not-found
    zgen oh-my-zsh plugins/npm
    zgen oh-my-zsh plugins/yarn
    zgen oh-my-zsh plugins/nvm
    zgen oh-my-zsh plugins/fnm
    zgen oh-my-zsh plugins/extract
    zgen oh-my-zsh plugins/ssh-agent
    zgen oh-my-zsh plugins/gpg-agent
    zgen oh-my-zsh plugins/macos
    zgen oh-my-zsh plugins/bgnotify
    zgen oh-my-zsh plugins/vscode
    zgen oh-my-zsh plugins/gh
    zgen oh-my-zsh plugins/common-aliases
    zgen oh-my-zsh plugins/direnv
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/docker-compose
    zgen oh-my-zsh plugins/node
    zgen oh-my-zsh plugins/deno

    # Your zsh-notify configuration here
    if [[ "$TERM_PROGRAM" != "vscode" && -n "$TERM_PROGRAM" ]]; then
      zgen load marzocchi/zsh-notify
    fi
    zgen load jeffreytse/zsh-vi-mode
    
    zgen oh-my-zsh plugins/bun
    zgen oh-my-zsh plugins/tldr
    zgen oh-my-zsh plugins/rbenv
    zgen oh-my-zsh plugins/jenv

    # Like cd but with z-zsh capabilities
    if command -v zoxide >/dev/null 2>&1; then
      zgen oh-my-zsh plugins/zoxide
    fi

    # Per-directory env vars
    if command -v direnv >/dev/null 2>&1; then
      zgen oh-my-zsh plugins/direnv
    fi

    # Custom plugins
    zgen load chriskempson/base16-shell
    zgen load djui/alias-tips
    zgen load hlissner/zsh-autopair
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-autosuggestions

    # Files
    zgen load $DOTFILES/lib
    zgen load $DOTFILES/custom

    # Load Spaceship prompt from remote
    if [[ ! -d "$SPACESHIP_PROJECT" ]]; then
      zgen load spaceship-prompt/spaceship-prompt spaceship
    fi

    # Completions
    zgen load zsh-users/zsh-completions src

    # Save all to init script
    zgen save
fi

# Load Spaceship form local project
if [[ -d "$SPACESHIP_PROJECT" ]]; then
  source "$SPACESHIP_PROJECT/spaceship.zsh"
fi

# Add custom pnpm section to Spaceship prompt
# spaceship_pnpm() {
#   # Check if pnpm is installed
#   [[ -z "$(command -v pnpm)" ]] && return

#   # Get pnpm version
#   local pnpm_version=$(pnpm --version)

#   # Display the section
#   spaceship::section::v4 \
#     --color "cyan" \
#     --prefix "via " \
#     --symbol "🅿 " \
#     --value "v${pnpm_version}"
# }

# # Add pnpm section to Spaceship prompt order
# SPACESHIP_PROMPT_ORDER=(
#   pnpm
#   # ... rest of your order ...
# )

# ------------------------------------------------------------------------------
# Load additional zsh files
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Overrides
# ------------------------------------------------------------------------------

# Source local configuration
if [[ -f "$HOME/.zshlocal" ]]; then
  source "$HOME/.zshlocal"
fi

# Get all the DGN secrets
if [ -f ~/.dgn_secrets ]; then
  #set -o allexport
  source ~/.dgn_secrets
  #set +o allexport
fi

if [ -f ~/.dgn_exports ]; then
  set -o allexport
  source ~/.dgn_exports
  set +o allexport
fi


# ------------------------------------------------------------------------------

# https://github.com/jeffreytse/zsh-vi-mode/issues/24
# Recommendation from Claude 3.5
# AND THEN initialize per-directory-history
HISTORY_START_WITH_GLOBAL=true
# Claude 3.5 recommendation to get ^G to work for insert mode in vi when first loading the directory
# zvm_after_init_commands+=('bindkey -M viins "^G" per-directory-history-toggle-history')

# Initialize iterm2 shell integration
. "$HOME/.cargo/env"
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Atuin - https://github.com/atuin/atuin
# https://docs.atuin.sh/reference/list/
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Bind Atuin after zsh-vi-mode initializes to prevent it from being overridden
zvm_after_init() {
  bindkey '^r' atuin-search # ctrl-r
  bindkey '^[[A' atuin-up-search # Up arrow
}
