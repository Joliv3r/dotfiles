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

# https://gitlab.com/farlusiva/dotfiles/
################################################################################
#                          fzf in the shell (config)
################################################################################

# When true, always simulate an 'enter' press to let the prompt update itself.
# This is the 'safe' option. False is for prompts that either automatically
# update the dirs themselves, like simple PS1 prompts, or p10k-based prompts,
# which we manually update here.
# If _fzf-edit looks weird, then this should probably be switched.

# Note: If using a simple PS1-based prompt where the dir automatically updates,
# this should be set to 'false'. This is because 'true' looks bad on ctrl-k.
# (Another solution would be to undo the commit that makes fzf-edit cd without
# using the BUFFER.)

_FZFEDIT_ALWAYS_ACCEPT_LINE="false"

# Command to update the user's prompt. Used by fzf-edit.
# Only needed for ctrl-o to look properly if _FZFEDIT_ALWAYS_ACCEPT_LINE is off.
# and very much needed if it is on (unless prompt updates are automatic like for
# simple PS1-based setups).
_fzf-edit_update_prompt() {

	# Powerlevel10k/powerlevel9k is probably in use
	if echo "$PS1" | grep -q "_p9k__" && \
	        typeset -f _p10k_redraw_prompt >/dev/null ; then
		_p10k_redraw_prompt
	fi
}

################################################################################
#                           fzf in the shell (code)
################################################################################

# Redraw the prompt. Used by _fzf-edit.
# https://github.com/romkatv/powerlevel10k/issues/2048#issuecomment-1271186812
function _p10k_redraw_prompt() {
  local f
  for f in chpwd "${chpwd_functions[@]}" precmd "${precmd_functions[@]}"; do
    [[ "${+functions[$f]}" == 0 ]] || "$f" &>/dev/null || true
  done
  p10k display -r
}

# For fzf (normal use w/o pipe) and for other programs that try to use it
FD_COMMAND="fd --hidden -I -E .git -E .cache -E .stversions" # For own use
export FZF_DEFAULT_COMMAND="$FD_COMMAND"
export FZF_DEFAULT_OPTS="--exact --bind=ctrl-z:ignore --tiebreak=length"

# Will find the first folder in the input (meant
# to be the pwd) that contains a .git directory.
_get_git_dir() {
	INP="$1"
	while :; do

		if [[ -d "$INP/.git" ]]; then
			echo "$INP"
			return 0
		fi

		if [[ "$INP" = "/" ]] || [[ -z $INP ]]; then
			return 1
		fi

		INP="$(dirname "$INP")"
	done
}

_get_direnv_dir() {
	INP="$1"
	while :; do

		if [[ -f "$INP/.envrc" ]]; then
			echo "$INP"
			return 0
		fi

		if [[ "$INP" = "/" ]] || [[ -z $INP ]]; then
			return 1
		fi

		INP="$(dirname "$INP")"
	done
}

# Edit a file or cd into its dir.
# Press ctrl-e => cd to dir and edit the file
# Press ctrl-t => edit the file (no cd)
# Press ctrl-k => cd to file (no edit)
# Press ctrl-r => open in ranger (ranger_cd, see above)
# Press enter: do same action as arg (ctrl-e, ctrl-t, ctrl-k)
# Note: $= makes zsh do word splitting: https://unix.stackexchange.com/a/461361

# Dependencies:
#	- fd, and $FD_COMMAND must be defined
#	- ranger and _ranger_cd (defined above) for ctrl-o
#	- $EDITOR must be defined and installed for ctrl-e and ctrl-t

# File input methods ("MODE"):
# 1: The files you select from are found in your working directory
# 2: The files you select from are from a preselected list of dirs, such as a
#    list of favourite dirs. Usually used for more "global" cd-ing.

# Usage examples:
# _fzf-edit ctrl-e 1
# _fzf-edit ctrl-k 2 -f fav_dirs.txt project_dirs.txt
# _fzf-edit ctrl-o 2 -d ~/Syncthing ~/dotfiles ~/programming_project

# Note: MODE=2 has not been tested for weird unicode-named files. MODE=1 has.

_fzf-edit() {
	if [[ -z "$1" ]]; then
		echo "$0: need to know default behaviour (ctrl-{e,k,t}); exiting."
		return 1
	fi
	DEF_PRESS="$1"
	if [[ -z "$2" ]]; then
		echo "$0: need to know file input methods (1 or 2)"
		return 1
	fi
	MODE="$2"
	shift
	shift
	FOLDER=()
	if [[ $MODE = "2" ]]; then
		# Motivating example: FOLDER=("~/Syncthing" "~/dotfiles")
		if [[ -z "$1" ]]; then
			echo "$0 needs dir(/s) (-d/-D) file(/s) to read dirs from (-f/-F)"
			return 1
		fi
		# -d: take in one dir, -f: read in dirs from one file.
		# -D: Like -d, but take all furthers args as -d's. Correspondingly -F.
		while [[ $# -ne 0 ]]; do
		case "$1" in
		-d) shift; FOLDER+=("$1"); shift ;;
		-D) shift; FOLDER+=("$@"); break ;;
		-f) shift; while read -r line; do FOLDER+=("$line"); done < $1; shift ;;
		-F) shift; while read -r line; do FOLDER+=("$line"); done < $@; break ;;
		*) echo "$0: Failed to parse args."; return 1 ;;
		esac
	done
	fi
	# Folder to search in.
	# If the _get_git_dir line is uncommented, search from the root of the git
	# repo the user is in, if one exists. (Else from current dir).
	if [[ $MODE = "1" ]]; then
		# We allow the "relative" stuff for mode 1, but not mode 2,
		# which has its own logic.
		FOLDER=("$(_get_git_dir "$(pwd)" || echo ".")")
		FOLDER=("$(realpath --relative-to=. "$FOLDER")")
	elif [[ $MODE = "2" ]]; then
		# Perform similar string processing as in the case above.
		for ((k = 1; k <= $#FOLDER; k++)); do
			# Perform string substitution to allow for literal ~ in the input
			TMP="$FOLDER[k]"
			TMP=${TMP//'~'/$HOME} # hack
			FOLDER[k]="$(realpath -z "$TMP")"
		done
	fi
	# TODO: Find a way to shorten the lengths of the output files in MODE=2.

	# give fd extra args to show paths as relative, when in a git repo and not
	# in its root.
	# Performance hit: Noticeable on nixpkgs (~30k lines). Therefore we only
	# do this when there are <5k items.
	FD_GIT_REL=""
	if [[ "$FOLDER" != "." ]] && [[ "$MODE" = 1 ]]; then
		# for 5k, this takes ~12 ms, says hyperfine, on hestia (NVME).
		tmp="$($=FD_COMMAND -t f -t l . $FOLDER --max-results 5000 | wc -l)"
		if [[ "$tmp" != "5000" ]]; then
			FD_GIT_REL="--batch-size 1000 -X realpath --relative-to=. -zsm"
		fi
	fi
	setopt localoptions pipefail no_aliases 2> /dev/null
	local sel="$($=FD_COMMAND -t f -t l -0 . $FOLDER $=FD_GIT_REL | fzf +m --reverse \
	          --height 10 --expect=ctrl-t,ctrl-e,ctrl-k,ctrl-r,ctrl-o \
	          --read0 $=FZF_DEFAULT_OPTS --bind=ctrl-j:accept)"
	local press="$(echo "$sel" | head -n 1)"
	sel="$(echo "$sel" | tail -n +2)"
	if [[ -z "$sel" ]]; then
		zle redisplay
		return 0
	fi
	# $press is "" if the 'normal' selection is done
	[[ -z "$press" ]] && press="${DEF_PRESS}"
	zle push-line # Clear buffer. Auto-restored on next prompt.
	local dir="$(dirname "$sel")"
	# TODO: Find a way to run vim/ranger without them complaining about
	# terminal mode. Then we can do everything without any 'accept-line'-s.
	local NEEDS_ACCEPT="" # for when we are going to run a command
	case "$press" in
	ctrl-e)
    customdir="$(_get_direnv_dir "$(realpath "$sel")")"
    if [ ! "$customdir" ]; then
      customdir="$(_get_git_dir "$(realpath "$sel")")"
    fi
		sel="$(realpath --relative-to="$customdir" "$sel")"
    dir="$(realpath --relative-to="$customdir" "$dir")"
		[[ "$dir" != "." ]] && builtin cd "$customdir"
		BUFFER+="$EDITOR ${(q)sel}; builtin cd '${dir}'"
		NEEDS_ACCEPT="true" ;;
	ctrl-r|ctrl-o)
		# cd without telling user for a shorter ranger command. Does not change
		# any functionality, as ranger_cd cd's after ran.
		sel="$(realpath --relative-to="$dir" "$sel")"
		[[ "$dir" != "." ]] && builtin cd "$dir"
		BUFFER=" ranger_cd --selectfile=${(q)sel}"
		NEEDS_ACCEPT="true" ;;
  ctrl-t)
		cur="$(pwd)"
    customdir="$(_get_direnv_dir "$(realpath "$sel")")"
    if [ ! "$customdir" ]; then
      customdir="$(_get_git_dir "$(realpath "$sel")")"
    fi
		sel="$(realpath --relative-to="$customdir" "$sel")"
		dir="$(realpath --relative-to="$customdir" "$dir")"
		[[ "$dir" != "." ]] && builtin cd "$customdir"
		BUFFER+="$EDITOR ${(q)sel}; builtin cd '${cur}'"
		NEEDS_ACCEPT="true" ;;ctrl-k) [[ "$dir" != "." ]] && builtin cd "$dir" ;;
	esac
	# Redraw the prompt before the 'accept_line' if we have cd'd, so that the
	# user sees we've cd'd before we run our command.
	# Note: This is slightly inefficient as we always update the prompt, even
	# when not needed (like ctrl-t). We assume this update is cheap. Also,
	# don't redraw in one specific case where it would look bad.
	if ! { [[ "$press" = "ctrl-k" ]] && \
	              [[ "${_FZFEDIT_ALWAYS_ACCEPT_LINE}" == "true" ]] }; then
		_fzf-edit_update_prompt
	fi
	if [[ "${NEEDS_ACCEPT}" == "true" ]] || \
	              [[ "${_FZFEDIT_ALWAYS_ACCEPT_LINE}" == "true" ]]; then
		zle accept-line
	fi
	local ret=$?
	unset sel press dir # ensure this doesn't end up appearing in prompt expansion
	zle reset-prompt
	return $ret
}

# Decide between the emacs <C-e> or fzf-edit when <C-e> is pressed.
# I've decided not to move fzf-edit to another bind (for now? <C-t> can work).
# It activates fzf-edit when the current line is empty.
_ctrl-e() {
	if [[ -z "$BUFFER" ]]; then
		_fzf-edit ctrl-e 1
	else
		zle end-of-line
	fi
}

zle -N _ctrl-e
bindkey "^E" _ctrl-e

_ctrl-k() {
	if [[ -z "$BUFFER" ]]; then
		_fzf-edit ctrl-k 1
	else
		zle kill-line
	fi
}
zle -N _ctrl-k
bindkey "^K" _ctrl-k

# Bind <C-j> on empty line to fzf-edit "global movement" mode.
_ctrl-j() {
	if [[ -z "$BUFFER" ]]; then
		_fzf-edit ctrl-k 2 -d ~/dotfiles -f ~/.fzfedit_files.txt
		#_fzf-edit ctrl-k 2 -f ~/list.txt
	else
		zle accept-line
	fi
}
zle -N _ctrl-j
bindkey "^J" _ctrl-j

# fzf-based file completion in zsh
# We use '. "$1"' instead of just a "$1" in order to complete paths that are
# partially written, such as when typing /usr/share/**<TAB>.

_fzf_compgen_path() {
	fd -H . "$1"
}

_fzf_compgen_dir() {
	fd -H -t f . "$1"
}

# Hack to get it to work on NixOS.
# The fzf path could be passed onto us here with an environment variable set in
# zsh.nix, but I reckon that this is better because it doesn't rely on zsh.nix.
source "$(dirname "$(realpath "$(which fzf)")")/../share/fzf/completion.zsh"

# Lookup for norwegian-english mathematical dictionary.
alias ord="tail -n +2 $HOME/matematisk_ordliste/verifiserte_termer.csv | fzf -d, --nth=1,2,3"

# Neofetch
neofetch --ascii_distro puppy

