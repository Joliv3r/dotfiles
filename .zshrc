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

# Start zsh
eval "$(starship init zsh)"

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Some Haskell shit
[ -f "/home/joliver/.ghcup/env" ] && source "/home/joliver/.ghcup/env" # ghcup-env

# Neofetch
neofetch --ascii_distro puppy

# Plugins
source /home/joliver/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax Highlighting
source /home/joliver/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# PATH
PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux/"
