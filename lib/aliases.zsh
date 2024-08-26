#
# Aliases
#

# Enable aliases to be sudo’ed
#   http://askubuntu.com/questions/22037/aliases-not-available-when-using-sudo
alias sudo='sudo '

_exists() {
  command -v $1 > /dev/null 2>&1
}

# Avoid stupidity with trash-cli:
# https://github.com/sindresorhus/trash-cli
# or use default rm -i
if _exists trash; then
  alias rm='trash'
fi

# Just bcoz clr shorter than clear
alias clr='clear'

# Go to the /home/$USER (~) directory and clears window of your terminal
alias q="~ && clear"

# Folders Shortcuts
[ -d ~/Downloads ]            && alias dl='cd ~/Downloads'
[ -d ~/Desktop ]              && alias dt='cd ~/Desktop'
[ -d ~/Projects ]             && alias pj='cd ~/Projects'
[ -d ~/Projects/Forks ]       && alias pjf='cd ~/Projects/Forks'
[ -d ~/Projects/Job ]         && alias pjj='cd ~/Projects/Job'
[ -d ~/Projects/Playground ]  && alias pjl='cd ~/Projects/Playground'
[ -d ~/Projects/Repos ]       && alias pjr='cd ~/Projects/Repos'

# Commands Shortcuts
alias e="$EDITOR"
alias -- +x='chmod +x'
alias x+='chmod +x'

# Open aliases
alias open='open_command'
alias o='open'
alias oo='open .'
alias term='open -a iterm.app'

# Run scripts
alias update="source $DOTFILES/scripts/update"
alias bootstap="source $DOTFILES/scripts/bootstrap"

# Quick jump to dotfiles
alias dotfiles="code $DOTFILES"

# Quick reload of zsh environment
alias reload="source $HOME/.zshrc"

# My IP
alias myip='ifconfig | sed -En "s/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p"'

# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get="curl -O -L"

# Yarn
alias ybw="yarn build:watch"
alias yba="yarn build:all"
alias ytw="yarn test:watch"

# Use tldr as help util
if _exists tldr; then
  alias help="tldr"
fi

alias git-root='cd $(git rev-parse --show-toplevel)'

# Better ls with icons, tree view and more
# https://github.com/eza-community/eza
if _exists eza; then
  unalias ls
  alias ls='eza --icons --header --git'
  alias lt='eza --icons --tree'
  unalias l
  alias l='ls -l'
  alias la='ls -lAh'
  alias ll='ls -alF' # can't use h flag with eza
else 
  alias ll='ls -alFh' # use h for human readable sizes
fi

# cat with syntax highlighting
# https://github.com/sharkdp/bat
if _exists bat; then
  # Run to list all themes:
  #   bat --list-themes
  export BAT_THEME='base16'
  alias cat='bat'
fi

# cd with zsh-z capabilities
# https://github.com/ajeetdsouza/zoxide
if _exists zoxide; then
  alias cd='z'
fi

# DNISHIYAMA ALIASES

# function to make "cd"ing more efficient
c() { cd "$@" && ll; }

# Alias to help with vim
if type nvim > /dev/null 2>&1; then
  alias v='nvim'
  alias vim='nvim'
else
  alias v='vim'
fi

# Environment managment to set DOTENV_KEY and run a command for a specific environment
with-env() {
    local env="$1"
    shift  # Remove the first argument (environment) from the argument list

    # Check if a command was provided
    if [ $# -eq 0 ]; then
        echo "Usage: with-$env <command>"
        return 1
    fi

    # Only prompt for confirmation if the environment is production
    if [ "$env" = "production" ]; then
        echo -n "Are you sure you want to set dotenv_key for PRODUCTION and run the command? (y/n) "
        read -r response

        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Operation cancelled."
            return 1
        fi
    fi

    # Set DOTENV_KEY
    # DOTENV_KEY=$(npx dotenv-vault keys "$env")
    
    if [ $? -eq 0 ]; then
        echo "DOTENV_KEY has been set for $env environment."
        
        # Run the provided command
        echo "Running command: $@"
        DOTENV_KEY=$(npx dotenv-vault keys "$env") "$@"
    else
        echo "Failed to set DOTENV_KEY. Command not executed."
    fi
}

# Specific functions for each environment
with-dev() {
    with-env "development" "$@"
}

with-ci() {
    with-env "ci" "$@"
}

with-staging() {
    with-env "staging" "$@"
}

with-prod() {
    with-env "production" "$@"
}

# -----------------------------------------------------------------------------
# AI-powered Git Commit Function - https://gist.github.com/karpathy/1dd0294ef9567971c1e4348a90d69285
# Copy paste this gist into your ~/.bashrc or ~/.zshrc to gain the `gai` command. It:
# 1) gets the current staged changed diff
# 2) sends them to an LLM to write the git commit message
# 3) allows you to easily accept, edit, regenerate, cancel
# But - just read and edit the code however you like
# the `llm` CLI util is awesome, can get it here: https://llm.datasette.io/en/stable/

gai() {
    # Function to generate commit message
    generate_commit_message() {
        git diff --cached | llm "
Below is a diff of all staged changes, coming from the command:
\`\`\`
git diff --cached
\`\`\`
Please generate a concise, one-line commit message for these changes."
    }

    # Function to read user input compatibly with both Bash and Zsh
    read_input() {
        if [ -n "$ZSH_VERSION" ]; then
            echo -n "$1"
            read -r REPLY
        else
            read -p "$1" -r REPLY
        fi
    }

    # Main script
    echo "Generating AI-powered commit message..."
    commit_message=$(generate_commit_message)

    while true; do
        echo -e "\nProposed commit message:"
        echo "$commit_message"

        read_input "Do you want to (a)ccept, (e)dit, (r)egenerate, or (c)ancel? "
        choice=$REPLY

        case "$choice" in
            a|A )
                if git commit -m "$commit_message"; then
                    echo "Changes committed successfully!"
                    return 0
                else
                    echo "Commit failed. Please check your changes and try again."
                    return 1
                fi
                ;;
            e|E )
                read_input "Enter your commit message: "
                commit_message=$REPLY
                if [ -n "$commit_message" ] && git commit -m "$commit_message"; then
                    echo "Changes committed successfully with your message!"
                    return 0
                else
                    echo "Commit failed. Please check your message and try again."
                    return 1
                fi
                ;;
            r|R )
                echo "Regenerating commit message..."
                commit_message=$(generate_commit_message)
                ;;
            c|C )
                echo "Commit cancelled."
                return 1
                ;;
            * )
                echo "Invalid choice. Please try again."
                ;;
        esac
    done
}