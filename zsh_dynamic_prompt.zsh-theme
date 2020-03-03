__prompt_time_min=10
__prompt_startup=true

# allow user defined __prompt_time_min_function function
# ======================================================
if ! builtin which __prompt_time_min_function &>/dev/null; then
	function __prompt_time_min_function() {
		return 0
	}
fi


# standart exit codes
# ===================

function exit_code_to_name() {
	local exit_code_name=""
	case "$1" in
		64) exit_code_name="EX_USAGE";;
		65) exit_code_name="EX_DATAERR";;
		66) exit_code_name="EX_NOINPUT";;
		67) exit_code_name="EX_NOUSER";;
		68) exit_code_name="EX_NOHOST";;
		69) exit_code_name="EX_UNAVAILABLE";;
		70) exit_code_name="EX_SOFTWARE";;
		71) exit_code_name="EX_OSERR";;
		72) exit_code_name="EX_OSFILE";;
		73) exit_code_name="EX_CANTCREAT";;
		74) exit_code_name="EX_IOERR";;
		75) exit_code_name="EX_TEMPFAIL";;
		76) exit_code_name="EX_PROTOCOL";;
		77) exit_code_name="EX_NOPERM";;
		78) exit_code_name="EX_CONFIG";;
		126) exit_code_name="Command invoked cannot execute";;
		127) exit_code_name="command not found";;
		128) exit_code_name="Invalid argument to exit";;
		129) exit_code_name="SIGHUP";;
		130) exit_code_name="SIGINT";;
		131) exit_code_name="SIGQUIT";;
		132) exit_code_name="SIGILL";;
		133) exit_code_name="SIGTRAP";;
		134) exit_code_name="SIGABRT";;
		135) exit_code_name="SIGIOT";;
		136) exit_code_name="SIGBUS";;
		137) exit_code_name="SIGFPE";;
		138) exit_code_name="SIGKILL";;
		139) exit_code_name="SIGUSR1";;
		140) exit_code_name="SIGSEGV";;
		141) exit_code_name="SIGUSR2";;
		142) exit_code_name="SIGPIPE";;
		143) exit_code_name="SIGALRM";;
		144) exit_code_name="SIGTERM";;
		145) exit_code_name="SIGSTKFLT";;
		146) exit_code_name="SIGCHLD";;
		147) exit_code_name="SIGCONT";;
		148) exit_code_name="SIGSTOP";;
		149) exit_code_name="SIGTSTP";;
		150) exit_code_name="SIGTSTP";;
		151) exit_code_name="SIGTTIN";;
		152) exit_code_name="SIGTTOU";;
		153) exit_code_name="SIGURG";;
		154) exit_code_name="SIGXCPU";;
		155) exit_code_name="SIGXFSZ";;
		156) exit_code_name="SIGVTALRM";;
		157) exit_code_name="SIGPROF";;
		158) exit_code_name="SIGWINCH";;
		159) exit_code_name="SIGIO";;
		160) exit_code_name="SIGPOLL";;
		161) exit_code_name="SIGPWR";;
		162) exit_code_name="SIGSYS";;
		163) exit_code_name="SIGRTMIN";;
		164) exit_code_name="SIGRTMIN+1";;
		165) exit_code_name="SIGRTMIN+2";;
		166) exit_code_name="SIGRTMIN+3";;
		167) exit_code_name="SIGRTMIN+4";;
		168) exit_code_name="SIGRTMIN+5";;
		169) exit_code_name="SIGRTMIN+6";;
		170) exit_code_name="SIGRTMIN+7";;
		171) exit_code_name="SIGRTMIN+8";;
		172) exit_code_name="SIGRTMIN+9";;
		173) exit_code_name="SIGRTMIN+10";;
		174) exit_code_name="SIGRTMIN+11";;
		175) exit_code_name="SIGRTMIN+12";;
		176) exit_code_name="SIGRTMIN+13";;
		177) exit_code_name="SIGRTMIN+14";;
		178) exit_code_name="SIGRTMIN+15";;
		179) exit_code_name="SIGRTMIN+16";;
		180) exit_code_name="SIGRTMIN+17";;
		181) exit_code_name="SIGRTMIN+18";;
		182) exit_code_name="SIGRTMIN+19";;
		183) exit_code_name="SIGRTMIN+20";;
		184) exit_code_name="SIGRTMIN+21";;
		185) exit_code_name="SIGRTMIN+22";;
		186) exit_code_name="SIGRTMIN+23";;
		187) exit_code_name="SIGRTMIN+24";;
		188) exit_code_name="SIGRTMIN+25";;
		189) exit_code_name="SIGRTMIN+26";;
		190) exit_code_name="SIGRTMIN+27";;
		191) exit_code_name="SIGRTMIN+28";;
		192) exit_code_name="SIGRTMIN+29";;
		193) exit_code_name="SIGRTMIN+30";;
	esac
	echo "$exit_code_name"
}


# ansifilter to remove escape sequences
# =====================================

if ! builtin which ansifilter &>/dev/null; then
	alias ansifilter='sed "s/\[[0-9;]*[a-zA-Z]//g"'
fi


# Append hostname on ssh connections
if [ -n "$SSH_CONNECTION" ]; then
	__prompt_hostname="@$HOST"
else
	__prompt_hostname=""
fi

# Don't show username if current user is equal to $__prompt_default_user
if [ "$USER" = "$__prompt_default_user" ]; then
	__prompt_user=""
elif [ "$USER" = "root" ]; then
	__prompt_user="%{[31m%}$USER "
else
	__prompt_user="$USER"
fi

# Allow commandline comments
if [ "${__prompt_allow_comments:-true}" = true ]; then
	set -k
fi

# Load zsh/datetime to determinate command execution time
zmodload zsh/datetime

function __zle_keymap_select() {
	local indicator=""
	case "$KEYMAP" in
		"emacs"|"viins"|"main")
			indicator=" [40;32mINSERT[0m"
			;;
		"vicmd")
			indicator="[41;33;1mCOMMAND[0m"
			;;
		"viopp")
			indicator="[45;37mSPECIAL[0m"
			;;
		"visual")
			indicator=" [43;30mVISUAL[0m"
			;;
		*)
			indicator="[41;37;5mUNKNOWN[0m"
			;;
	esac
	local indicator_no_ansi="$(ansifilter <<<"$indicator")"
	echo -ne "\e[s\e[1;$((COLUMNS-${#indicator_no_ansi}+1))H${indicator}\e[u"
}
# do not just to show current vim mode if already defined by another plugin
zle -l | grep -q zle-keymap-select || zle -N zle-keymap-select __zle_keymap_select
zle -N zle-line-init __zle_keymap_select

# Pre command hook
function __pre_cmd_prompt() {
	__prompt_cmd_start="$EPOCHSECONDS"
	__prompt_cmd_started="$1"  # safe currect command, for later usage
	local cmd_lines="$(wc -l <<<"$__prompt_cmd_started")"  # calculate the number of new lines in current command
	echo -n "[s[1G[${cmd_lines}A[0;1;32m╰[0m[u"  # redraw first char in promptline
}
function __post_cmd_prompt() {
	local err_code="$?"
	if [ -z "$__prompt_cmd_started" ]; then
		return
	fi
	__prompt_last_cmd_runtime="$((EPOCHSECONDS-__prompt_cmd_start))"

	local command_time="" h m s
	if [ "$__prompt_last_cmd_runtime" -gt "$__prompt_time_min" ]; then
		h="$((__prompt_last_cmd_runtime/60/60))"
		m="$((__prompt_last_cmd_runtime/60-h*60))"
		s="$((__prompt_last_cmd_runtime%60))"
		command_time="$(printf "%d:%02d:%02d" "$h" "$m" "$s")"
		__prompt_time_min_function "$__prompt_cmd_started" "$command_time" "$err_code"
	fi

	local err_msg
	err_msg="$(exit_code_to_name "$err_code")"

	export git_status git_branch git_branch_remote git_added git_modified git_deleted git_untracked
	git_status="$(git status --porcelain=v1 --branch 2>/dev/null)"
	git_branch="$(head -n1 <<< "$git_status" | cut -d ' ' -f 2)"
	git_branch_remote="$(grep '\..'<<<"$git_branch" | cut -d '.' -f 4)"
	git_branch="$(cut -d '.' -f 1 <<<"$git_branch")"
	git_added="$(grep "^[ ]\?A" <<<"$git_status" | wc -l)"
	git_modified="$(grep "^[ ]\?M" <<<"$git_status" | wc -l)"
	git_deleted="$(grep "^[ ]\?D" <<<"$git_status" | wc -l)"
	git_untracked="$(grep "^[ ]\??" <<<"$git_status" | wc -l)"
	git_hash="$(git rev-parse --short HEAD 2>/dev/null)"
	if [ "$(head -n1 <<< "$git_status" | cut -d ' ' -f 3,4)" = "(no branch)" ]; then
		git_branch="$(git show --summary | head -n1 | cut -c 8-14)"
	fi

	local r_prompt="" git_line=""
	if [ -n "$git_branch" ]; then
		[ "$git_untracked" -gt 0 ] && git_line+=" [1;38;5;248m?:[0;38;5;248m$git_untracked"
		[ "$git_added" -gt 0 ]     && git_line+=" [1;32mA:[0;32m$git_added"
		[ "$git_modified" -gt 0 ]  && git_line+=" [1;33mM:[0;33m$git_modified"
		[ "$git_deleted" -gt 0 ]   && git_line+=" [1;31mD:[0;31m$git_deleted"
		git_line+=" [1;35m◀"
		git_line+="[1;33m$git_branch"
		[ -n "$git_branch_remote" ] && git_line+="|[0;3;33m$git_branch_remote"
		git_line+="[1;35m▶[0m"
		git_line+=" [1;32m─"
		r_prompt+="$git_line"
		l_git_line="[1;3;38;2;0;125;255m$git_hash"
	else
		l_git_line=""
	fi
	if [ "$err_code" -gt 0 ]; then
		[ -n "$err_msg" ] && err_msg=" $err_msg"
		r_prompt+=" [1;31m[$err_code][0;31m$err_msg"
	else
		r_prompt+=" [1;32m$err_code"
	fi
	r_prompt+="[1;32m ╯"

#	local cols r_prompt_no_ansi
	cols="${COLUMNS:-$(tput cols)}"
	r_prompt_no_ansi="$(ansifilter <<<"$r_prompt")"
	cols="$((cols-${#r_prompt_no_ansi}))"

	echo -ne "\e[1;32m"
	printf "%*s" "$cols" "" | sed "s/ /─/g"  # draw full hr line
	echo -n "$r_prompt"

	if [ $((${#r_prompt_no_ansi}+${#PWD}+${#command_time}+6)) -gt "$COLUMNS" ]; then  # if line to long
		printf "\r[0;1;32m╭─"
		[ -n "$l_git_line" ]   && printf "[1;32m╢$l_git_line[1;32m╟"
		printf "\n"
		[ -n "$command_time" ] && printf "[0;1;32m├─ [0;32m[0;1;38;5;130m$command_time\n"
		printf "[0;1;32m├─ [0;32m[0;38;5;246m$PWD\n"
		RPS1="%{[0;38;5;246m%}%~%{[0m%}"
	else  # line not to long
		[ -n "$command_time" ] && command_time="\e[0;1;32m─\e[0;1;38;5;130m $command_time "
		[ -n "$l_git_line" ]   && l_git_line="[1;32m───╢$l_git_line[1;32m╟"
		printf "\r\e[0;1;32m╭─\e[0m \e[0;38;5;246m${PWD} $l_git_line$command_time\e[0m\n" "$h" "$m" "$s"
		RPS1="%{[0;38;5;246m%}%~%{[0m%} %D{%H:%M:%S}"
	fi
	if [ -n "${NIX_SHELL_PACKAGES+1}" ]; then
		__prompt_nix_shell="%{[1;32m%}[%{[0;3;38;5;28m%}NIX-SHELL%{[0;1;32m%}] "
	else
		__prompt_nix_shell=""
	fi

	__prompt_cmd_started=""
}
__prompt_cmd_started="# started"
__prompt_cmd_start="$EPOCHSECONDS"
__post_cmd_prompt
PS1="%{[1;32m%}├─ %{[0;32m%}$__prompt_nix_shell%{[0;32m%}$__prompt_user%{[1;32m%}$__prompt_hostname%(!.%{[1;31m%}#.%{[1;32m%}$) %{[0m%}"
add-zsh-hook preexec __pre_cmd_prompt
add-zsh-hook precmd __post_cmd_prompt

