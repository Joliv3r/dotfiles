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
alias gc="git commit"
alias gdh="git diff HEAD"
alias gs="git status"
alias ga="git add"
alias gp="git pull"

# Other aliases
alias ls='ls --color=auto'
alias la='ls -A'
alias grep='grep --color=auto'
alias cdd="builtin cd /home/joliver/.dotfiles/"

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

# JAWK-style navigation shortcuts
alias -g ..=".."
alias -g ...="../.."
alias -g ....="../../.."
alias -g .....="../../../.."

# nix develop with zsh
alias dev="nix develop --command \$SHELL"
alias isodev="nix develop --ignore-env --command sh --norc"

bindkey -e

# Zoxide
eval "$(zoxide init --cmd cd zsh)"

# Some Haskell shit
# [ -f "/home/joliver/.ghcup/env" ] && source "/home/joliver/.ghcup/env" # ghcup-env

# PATH
PATH="$PATH:/usr/local/texlive/2023/bin/x86_64-linux/"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


################################################################################
#                         Make nix shells
################################################################################

mk-direnv () {
  echo use_nix > .envrc && direnv allow .
}

mk-nix-shell () {
  if [ $# -eq 0 ]; then
    echo "No argument supplied"
    return 1
  else
    if [ -f ./default.nix ]; then
      echo -n "default.nix already exists do you really want to override it? [y/N] "
      read answer
      case $answer in
        y|Y)
          ;;
        *)
          echo "Nothing is being done."
          return 1
          ;;
      esac
    fi
    if [ -f ./.envrc ]; then
      echo -n ".envrc already exists do you want to override it? [y/N] "
      read answer
      case $answer in
        y|Y)
          REPLACE_ENVRC=true
          ;;
        *)
          REPLACE_ENVRC=false
          ;;
      esac
    fi
    case $1 in
      rust)
        if [ ! -f ./rust-toolchain.toml ]; then
          cp /etc/nixos/shell/rust-toolchain.toml ./
        fi
        cp /etc/nixos/shell/rust.nix ./default.nix
        ;;
      *)
        if [ -f "/etc/nixos/shell/$1.nix" ]; then
          cp "/etc/nixos/shell/$1.nix" ./default.nix
        else
          echo "Invalid argument, no shell file of this type exists"
          return 1
        fi
        ;;
    esac
    if $REPLACE_ENVRC; then
      mk-direnv
    fi
  fi
}

alias mk_direnv=mk-direnv
alias mk_shell=mk-nix-shell


################################################################################
#                         Open nvim in root of direnv or git folder
################################################################################

nvim-cd () {
  if [ "$DIRENV_DIR" ]; then
    CURRENT_PATH="$(pwd)"
    builtin cd "${DIRENV_DIR:1}" || return 1
    nvim "$CURRENT_PATH/$1"
    builtin cd "$CURRENT_PATH" || return 1
  elif GIT_ROOT_PATH="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    CURRENT_PATH="$(pwd)"
    builtin cd "$GIT_ROOT_PATH" || return 1
    nvim "$CURRENT_PATH/$1"
    builtin cd "$CURRENT_PATH" || return 1
  else
    nvim "$1"
  fi
}

alias vim=nvim-cd

# fzfedit from https://gitlab.com/farlusiva/dotfiles
tmp="$HOME/.config/zsh/fzfedit.zsh"
[[ -f $tmp ]] && source $tmp
unset tmp

# Lookup for norwegian-english mathematical dictionary.
alias ord="tail -n +2 $HOME/matematisk_ordliste/verifiserte_termer.csv | fzf -d, --nth=1,2,3"

# Fastfetch
fastfetch
