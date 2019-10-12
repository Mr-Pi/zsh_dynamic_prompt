__prompt_time_min=10


function __prompt_time_min_function() {
	local cmd="$1" cmd_time="$2" ignore_cmd
	for ignore_cmd in "bash" "nix-shell" "vim" "less" "man" "sleep" "htop"; do
		[[ "$cmd" =~ "^$ignore_cmd" ]] && return 0
	done
	dunstify --appname="cmd_notify" -t 4000 -u normal "command: $cmd" "command $cmd has finished after $cmd_time."
}


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
if [ "${__prompt_allow_comments:-true}" = false ]; then
	set -k
fi

# Load zsh/datetime to determinate command execution time
zmodload zsh/datetime

# Pre command hook
function __pre_cmd_prompt() {
	__prompt_cmd_start="$EPOCHSECONDS"
	__prompt_cmd_started="$1"  # safe currect command, for later user
	local cmd_lines="$(wc -l <<<"$__prompt_cmd_started")"  # calculate the number of new lines in current command
	echo -n "[s[99999D[${cmd_lines}A[0;1;32m╰[0m[u"  # redraw first char in promptline
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
		__prompt_time_min_function "$__prompt_cmd_started" "$command_time"
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

	local r_prompt="" git_line=""
	if [ -n "$git_branch" ]; then
		[ "$git_untracked" -gt 0 ] && git_line+=" [1;38;5;248m?:[0;38;5;248m$git_untracked"
		[ "$git_added" -gt 0 ]     && git_line+=" [1;32mA:[0;32m$git_added"
		[ "$git_modified" -gt 0 ]  && git_line+=" [1;33mM:[0;33m$git_modified"
		[ "$git_deleted" -gt 0 ]   && git_line+=" [1;31mD:[0;31m$git_deleted"
		git_line+=" [1;35m◀"
		git_line+="[1;33m$git_branch"
		[ -n "$git_branch_remote" ] && git_line+="|[0;3;33m$git_branch_remote"
		git_line+="[1;35m▶[0m [1;32m─"
		r_prompt+="$git_line"
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
	printf "%*s" "$cols" "" | sed "s/ /─/g"
	echo -n "$r_prompt"

	if [ $((${#r_prompt_no_ansi}+${#PWD}+${#command_time}+6)) -gt "$COLUMNS" ]; then
		echo -e "\r\e[0;1;32m╭─"
		[ -n "$command_time" ] && echo -e "\e[0;1;32m├─ \e[0;32m\e[0;1;38;5;130m$command_time"
		echo -e "\e[0;1;32m├─ \e[0;32m\e[0;38;5;246m$PWD"
		RPS1="%{[0;38;5;246m%}%~%{[0m%}"
	else
		if [ -n "$command_time" ]; then
			printf "\r\e[0;1;32m╭─\e[0m \e[0;38;5;246m${PWD} \e[0;1;32m─\e[0;1;38;5;130m $command_time \e[0m\n" "$h" "$m" "$s"
		else
			printf "\r\e[0;1;32m╭─\e[0m \e[0;38;5;246m${PWD} \e[0m\n" "$h" "$m" "$s"
		fi
		RPS1="%{[0;38;5;246m%}%~%{[0m%} %D{%H:%M:%S}"
	fi
	if [ -n "${NIX_SHELL_PACKAGES+1}" ]; then
		__prompt_nix_shell="%{[1;32m%}[%{[0;3;38;5;28m%}NIX-SHELL%{[0;1;32m%}] "
	else
		__prompt_nix_shell=""
	fi

	__prompt_cmd_started=""
}
__pre_cmd_prompt "..."
__post_cmd_prompt
PROMPT="%{[1;32m%}├─ %{[0;32m%}$__prompt_nix_shell%{[0;32m%}$__prompt_user%{[1;32m%}$__prompt_hostname%(!.%{[1;31m%}#.%{[1;32m%}$) %{[0m%}"
add-zsh-hook preexec __pre_cmd_prompt
add-zsh-hook precmd __post_cmd_prompt

