# --- 1. ENVIRONMENT & PATHS ---
export LANG=en_US.UTF-8
export EDITOR="micro" 

export "MICRO_TRUECOLOR=1"
export EXPOSWAYDIR="$HOME/.local/state/exposway/"
export EXPOSWAYMON="$HOME/.local/state/exposway/output"

# --- 2. THE GREETER ---
if [[ -o interactive ]]; then
    clear
    fastfetch
fi

# --- 3. NATIVE COMPLETIONS ---
autoload -Uz compinit && compinit -i

zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=*'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# --- 4. HISTORY CONFIGURATION ---
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt append_history        
setopt share_history         
setopt hist_ignore_dups      
setopt hist_ignore_space     

# --- 5. EXTERNAL PLUGINS (NixOS Paths) ---
if [ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
    source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

if [ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
    source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# --- 6. PROMPT ---
setopt prompt_subst
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

PROMPT='%F{2}%n@%m%f:%F{4}%~%f %F{5}${vcs_info_msg_0_}%f
%F{8}❯%f '

# aliases
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Nix Helper 
alias rebuild='nh os switch'
alias update='nh os switch --update'
alias clean='nh clean all --keep 3'
