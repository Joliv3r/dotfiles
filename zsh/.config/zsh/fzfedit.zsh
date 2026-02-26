# Original script can be found here:
# https://gitlab.com/farlusiva/dotfiles/-/blob/54e1063fd60a5509e6fc125465b7dd1db6bafea8/zsh/.config/zsh/fzfedit.zsh
# This file is a modified version.
# 
# fzfedit.zsh
#
# Edit a file or cd into its dir.
#
# Default keybinds:
# Press ctrl-e => cd to dir and edit the file
# Press ctrl-t => edit the file (no cd)
# Press ctrl-k => cd to file (no edit)
# Press ctrl-o => show pdf in viewer
# Press enter: do same action as arg (ctrl-e, ctrl-t, ctrl-k)
# Usage: Source this file in your zshrc
#
# Dependencies:
#	- fd, and $FD_COMMAND must be defined (we do it here if unset)
#	- $EDITOR for ctrl-e and ctrl-t
#	- $PDF_VIEWER for ctrl-o
#	- if not setting _fzf-edit_update_prompt by yourself, the helper function
#	  _reset_the_prompt.

################################################################################
#                               helper functions
################################################################################

# An attempt to reset the prompt. Also set in my normal zshrc, so only declare
# this here if the user hasn't made their own.
#
# Used by _fzf-edit
# https://github.com/romkatv/powerlevel10k/issues/2048#issuecomment-1271186812
if ! declare -f _reset_the_prompt >/dev/null 2>&1; then
	_reset_the_prompt() {
		local f
		for f in chpwd "${chpwd_functions[@]}" precmd "${precmd_functions[@]}"; do
			[[ "${+functions[$f]}" == 0 ]] || "$f" &>/dev/null || true
		done
		# Note: We could use a 'p10k display -r'-based solution if it turns out
		# that this isn't good enough, but that is p10k-specific, so undesirable.
		zle reset-prompt
	}
fi

################################################################################
#                                    config
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
	_reset_the_prompt
}

# Try to set a sensible default FD_COMMAND if none is found.
# Also, use fdfind if found (e.g. Ubuntu, Debian), else fd.
if ! (( ${+FD_COMMAND} )); then
	which fdfind >/dev/null 2>&1 && tmp="fdfind" || tmp="fd"
	FD_COMMAND="${tmp} --hidden -I -E .git -E .cache -E .stversions"
	unset tmp
fi

# Extra arguments given to fzf.
FZFEDIT_EXTRA_FZF_OPTS="--height 10"

################################################################################
#                                   keybinds
################################################################################

# Set the keybinds to use inside fzf-edit
typeset -A _fzfedit_keybinds=(
	[ctrl-e]="edit_cd"
	[ctrl-t]="edit_nocd"
	[ctrl-o]="zathura_nocd"
  [ctrl-k]="cd"
	# [ctrl-r]="ranger"
)

# Decide between the emacs <C-e> or fzf-edit when <C-e> is pressed. The latter
# only when the line is empty, and so the usual emacs <C-e> is a no-op.
_ctrl-e() {
	if [[ -z "$BUFFER" ]]; then
		_fzf-edit edit_cd 1
	else
		zle end-of-line
	fi
}

zle -N _ctrl-e
bindkey "^E" _ctrl-e

_ctrl-k() {
	if [[ -z "$BUFFER" ]]; then
		_fzf-edit cd 1
	else
		zle kill-line
	fi
}
zle -N _ctrl-k
bindkey "^K" _ctrl-k

_ctrl-o() {
	if [[ -z "$BUFFER" ]]; then
     local FD_COMMAND="$FD_COMMAND -e pdf -e djvu"
     _fzf-edit zathura_nocd 1
	else
		zle kill-line
	fi
}
zle -N _ctrl-o
bindkey "^O" _ctrl-o

# Bind <C-j> on empty line to fzf-edit "global movement" mode.
_ctrl-j() {
	if [[ -z "$BUFFER" ]]; then
		_fzf-edit cd 2 -d ~/dotfiles -f ~/.fzfedit_files.txt
		#_fzf-edit cd 2 -f ~/list.txt
	else
		zle accept-line
	fi
}
zle -N _ctrl-j
bindkey "^J" _ctrl-j

################################################################################
#                           fzf in the shell (code)
################################################################################

# Will find the first folder in the input (meant to be the pwd) that contains a
# .git directory.
_get_git_dir() {
	INP="$1"
	while :; do

		if [[ -d "$INP/.git" ]]; then
			echo "$INP"
			return 0
		fi

		if [[ "$INP" = "/" || -z $INP ]]; then
			return 1
		fi

		INP="$(dirname "$INP")"
	done
}

# Format paths before showing them to the user.
# Usage of this command (and therefore _unformat_path) in fzf_edit is optional.
# The formatting function uses NULs because it's only used in a NUL-ed pipeline.
# The ORS/RS behaviour is as it should be on GNU awk and mawk, but not on
# busybox awk???
_format_paths() {
	awk -v HOME="$HOME" -v ORS="\0" -v RS="\0" '
	{
		gsub("^" HOME, "~", $0) # Replace $HOME with ~
		gsub("^\\./", "", $0) # Remove "./" in front of every relative path
		print
	}'
}
# Gives full paths out. Doesn't use NULs as it's not used in a NUL pipeline.
_unformat_path() {
	awk -v HOME="$HOME" '{gsub(/^~/, HOME, $0); print}'
}

# Note: $= makes zsh do word splitting: https://unix.stackexchange.com/a/461361

# File input methods ("MODE"):
# 1: The files you select from are found in your working directory
# 2: The files you select from are from a preselected list of dirs, such as a
#    list of favourite dirs. Usually used for more "global" cd-ing.

# Usage examples:
# _fzf-edit edit_cd 1
# _fzf-edit cd 2 -f fav_dirs.txt project_dirs.txt
# _fzf-edit ranger 2 -d ~/Syncthing ~/dotfiles ~/programming_project

# Note: MODE=2 has not been tested for weird unicode-named files. MODE=1 has.

_fzf-edit() {
	if [[ -z "$1" ]]; then
		echo "$0: need to know default action (${(v)_fzfedit_keybinds}); exiting."
		return 1
	fi
	local DEF_ACTION="$1"
	if [[ -z ${(k)_fzfedit_keybinds[(r)$DEF_ACTION]} ]]; then # https://stackoverflow.com/a/63870549
		echo "$0: Default action must be valid. Here: $1; must be one of ${(v)_fzfedit_keybinds}."
		return 1
	fi
	if [[ -z "$2" ]]; then
		echo "$0: need to know file input methods (1 or 2)"
		return 1
	fi
	local MODE="$2"
	shift 2
	local FOLDER=()
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
	# Folder to search in. If the _get_git_dir line is there, search from the
	# root of the git repo the user is in (if in one). Else from current dir.
	if [[ $MODE = "1" ]]; then
		# We allow the "relative" stuff for mode 1, but not mode 2,
		# which has its own logic.
		FOLDER=("$(_get_git_dir "$(pwd)" || echo ".")")
		FOLDER=("$(realpath --relative-to=. "$FOLDER")")
	elif [[ $MODE = "2" ]]; then
		# Perform similar string processing as in the case above.
		for ((k = 1; k <= $#FOLDER; k++)); do
			# Perform string substitution to allow for literal ~ in the input
			local TMP=${FOLDER[k]}
			[[ ${TMP[1]} = "~" ]] && TMP=${TMP/'~'/$HOME}
			FOLDER[k]="$(realpath -z "$TMP")"
		done
	fi
	# give fd extra args to show paths as relative, when in a git repo and not
	# in its root.
	# Performance hit: Noticeable on nixpkgs (~30k lines). Therefore we only
	# do this when there are <5k items.
	FD_GIT_REL=""
	if [[ "$FOLDER" != "." && "$MODE" = 1 ]]; then
		# for 5k, this takes ~12 ms, says hyperfine, on hestia (NVME).
		tmp="$($=FD_COMMAND -t f -t l . $FOLDER --max-results 5000 | wc -l)"
		if [[ "$tmp" != "5000" ]]; then
			FD_GIT_REL="--batch-size 1000 -X realpath --relative-to=. -zsm"
		fi
	fi
	setopt localoptions pipefail no_aliases 2> /dev/null
	# Compute the expected presses, e.g. 'ctrl-t,ctrl-e,ctrl-k,ctrl-r,ctrl-o'
	# Hope there are no spaces in _fzfedit_keybinds.
	local expectedpresses="$(tr ' ' ',' <<< ${(k)_fzfedit_keybinds})"
	local sel="$($=FD_COMMAND -t f -t l -0 . $FOLDER $=FD_GIT_REL | \
		_format_paths | fzf --scheme=path +m --reverse \
	          --expect=$expectedpresses --read0 $=FZF_DEFAULT_OPTS \
	          $=FZFEDIT_EXTRA_FZF_OPTS)"
	local press="$(head -n 1 <<< $sel)"
	sel="$(tail -n +2 <<< $sel | _unformat_path)"
	if [[ -z "$sel" ]]; then
		zle redisplay
		return 0
	fi
	# Find the action to do. $press is "" if the 'normal' selection is done. As
	# is, we can e.g. put '[]="ranger"' as a keybind to bind enter/ctrl-m.
	local action=$_fzfedit_keybinds[$press]
	[[ -z "$action" ]] && action="${DEF_ACTION}"
	zle push-line # Clear buffer. Auto-restored on next prompt.
	local dir="$(dirname "$sel")"
	# TODO: Find a way to run vim/ranger without them complaining about
	# terminal mode. Then we can do everything without any 'accept-line'-s.
	local NEEDS_ACCEPT="" # for when we are going to run a command
	local TMP=""
	case "$action" in
	edit_cd)
		sel="$(realpath --relative-to="$dir" "$sel")"
		[[ "$dir" != "." ]] && builtin cd "$dir"
		BUFFER+="$EDITOR ${(q)sel}"
		NEEDS_ACCEPT="true" ;;
	ranger)
		# cd without telling user for a shorter ranger command. Does not change
		# any functionality, as ranger_cd cd's after ran.
		sel="$(realpath --relative-to="$dir" "$sel")"
		[[ "$dir" != "." ]] && builtin cd "$dir"
		[[ "${sel:0:1}" == "." ]] && TMP="--cmd='set show_hidden true'"
		BUFFER=" ranger_cd $TMP --selectfile=${(q)sel}"
		NEEDS_ACCEPT="true" ;;
	edit_nocd) BUFFER+=" $EDITOR ${(q)sel}" && NEEDS_ACCEPT="true";;
	cd) [[ "$dir" != "." ]] && builtin cd "$dir" ;;
  zathura_nocd) BUFFER+=" $PDF_VIEWER ${(q)sel}" && NEEDS_ACCEPT="true";;
	*) echo "$0: Action not found: '$action'" ;;
	esac
	# Redraw the prompt before the 'accept_line' if we have cd'd, so that the
	# user sees we've cd'd before we run our command.
	# Note: This is slightly inefficient as we always update the prompt, even
	# when not needed (like ctrl-t). We assume this update is cheap. Also,
	# don't redraw in one specific case where it would look bad.
	if ! { [[ "$action" = "cd" && \
	              "${_FZFEDIT_ALWAYS_ACCEPT_LINE}" == "true" ]] }; then
		_fzf-edit_update_prompt
	fi
	if [[ "${NEEDS_ACCEPT}" == "true" || \
	              "${_FZFEDIT_ALWAYS_ACCEPT_LINE}" == "true" ]]; then
		zle accept-line
	fi
	local ret=$?
	unset TMP NEEDS_ACCEPT sel press action expectedpresses dir # ensure this doesn't end up appearing in prompt expansion
	zle reset-prompt
	return $ret
}
