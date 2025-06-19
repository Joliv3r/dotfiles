# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# Plugins
source /home/joliver/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/joliver/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Autocompletion
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Start zsh
source $HOME/powerlevel10k/powerlevel10k.zsh-theme

eval "$(direnv hook zsh)"

# Git aliases
alias gc="git commit -m"
alias gdh="git diff HEAD"
alias gs="git status"
alias ga="git add"
alias gp="git pull"

# Other aliases
alias ls='ls --color=auto'
alias la='ls -A'
alias grep='grep --color=auto'
alias vim="nvim"
alias cdd="cd /home/joliver/.dotfiles/"

# Aliases for opening books
alias galois='zathura /home/joliver/skool/books/BasicAbstractAlgebra.djvu'
alias tplgc='zathura /home/joliver/skool/books/JanichTopology.djvu'
alias tplg='zathura /home/joliver/skool/books/MunkresTopologyFirstCourse.djvu'
alias opti='zathura /home/joliver/skool/books/NumericalOptimization.pdf'

# Hacky alias for venv
alias venv='source /home/joliver/.venv/bin/activate'

# Dangerous
alias sd='shutdown'

# Options
export VISUAL=nvim
export EDITOR=$VISUAL

bindkey -e

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Some Haskell shit
# [ -f "/home/joliver/.ghcup/env" ] && source "/home/joliver/.ghcup/env" # ghcup-env

# Neofetch
neofetch --ascii_distro puppy

# PATH
PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux/"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
