# ==================
#  Basic Paths & Tools
# ==================

export PATH="$HOME/.local/bin:$PATH"

# Pyenv (optional, only if installed)
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi

# NVM (Node Version Manager)
if [[ -d "$HOME/.nvm" ]]; then
  export NVM_DIR="$HOME/.nvm"
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
fi

# ==================
# Oh My Zsh 
# ==================
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  export ZSH="$HOME/.oh-my-zsh"
  ZSH_THEME="robbyrussell"
  source "$ZSH/oh-my-zsh.sh"
fi

# ==================
#  Prompt
# ==================
PROMPT='%F{white}%BArchlinux%f%F{magenta}_%f%F{blue}Dionysus%f %F{black}❯%f '

# Syntax highlighting / autosuggestions
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

# ==================
# Plugins
# ==================
[[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]] && \
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

[[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh" ]] && \
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

autoload -Uz compinit && compinit -C   # cache completions


# ==================
# Aliases & Functions
# ==================
# Bash-compatible aliases (transferred from .bashrc)
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Load custom aliases/functions if they exist
[[ -f "$HOME/.config/zsh/aliases.zsh" ]] && source "$HOME/.config/zsh/aliases.zsh"
[[ -f "$HOME/.config/zsh/functions.zsh" ]] && source "$HOME/.config/zsh/functions.zsh"

# ==================
#  Animated Neofetch Splash
# ==================
if [[ -n $PS1 ]]; then
   ~/.config/neofetch/animated-neofetch.sh 0.05
  clear
fi
