# --- 1. ENVIRONMENT & PATHS ---
export LANG=en_US.UTF-8
export EDITOR="nano" # Change to your preferred editor

# --- 2. THE GREETER ---
# Runs fastfetch only in interactive shells, ignoring background scripts
if [[ -o interactive ]]; then
    clear
    fastfetch
fi

# --- 3. NATIVE COMPLETIONS (The 'Zsh' Way) ---
# Add external completion paths (like zsh-completions) to the function path
if [ -d /usr/share/zsh/site-functions ]; then
    fpath=(/usr/share/zsh/site-functions $fpath)
fi

# Initialize the advanced completion system silently, ignoring insecure directory warnings
autoload -Uz compinit && compinit -i

# Case-insensitive matching, treating underscores/hyphens interchangeably
zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=*'

# Style the completion menu to navigate with arrow keys
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Match LS_COLORS inside menu

# --- 4. HISTORY CONFIGURATION ---
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt append_history        # Append to history file instead of overwriting
setopt share_history         # Share history across all active sessions
setopt hist_ignore_dups      # Don't record a line if it was the previous exact command
setopt hist_ignore_space     # Don't record lines starting with a space

# --- 5. EXTERNAL PLUGINS (Arch Linux Paths) ---
# Source the syntax highlighting and autosuggestions installed via pacman
[[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

[[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
    source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Customize the look of the autocomplete text (Default is a subtle gray)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# --- 6. PROMPT ---
# Enable parameter expansion, command substitution, and arithmetic expansion in prompts
setopt prompt_subst

# A clean, minimal two-line prompt that shows user@host, current directory, and Git branch
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

PROMPT='%F{2}%n@%m%f:%F{4}%~%f %F{5}${vcs_info_msg_0_}%f
%F{8}❯%f '

# --- 7. QUALITY OF LIFE ALIASES ---
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Arch Package Management (Pacman & Yay)
alias yas='yay -S'          # Install a package (includes AUR)
alias yar='yay -Rns'        # Remove package and its unused dependencies
alias yau='yay -Syu'        # Update the entire system (Repo + AUR)
alias yaq='yay -Ss'         # Search for a package in repos and AUR
export "MICRO_TRUECOLOR=1"
export EXPOSWAYDIR="$HOME/.local/state/exposway/"
export EXPOSWAYMON="$HOME/.local/state/exposway/output"
# Created by newuser for 5.9.1
