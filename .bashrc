#
# ~/.bashrc
#

# vi mode for bash
set -o vi

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1='\[\033[01;31m\][\h\[\033[01;36m\] \W\[\033[01;31m\]]\$\[\033[00m\] '
	else
		PS1='\[\033[01;32m\][\u@\h\[\033[01;37m\] \W\[\033[01;32m\]]\$\[\033[00m\] '
	fi

	alias ls='ls --color=auto'
	#alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

unset use_color safe_term match_lhs sh

alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias rm='trash'
#alias np='nano -w PKGBUILD'
#alias more=less
alias cat='bat'
alias grep='rg'

alias x='xdg-open'
alias C='xclip'
alias V='xclip -o'
alias vi='nvim'
alias pacup='sudo pacman -Syyu'
alias yayup='yay -Syyu'

alias ga='git add'
alias gco='git commit'
alias gch='git checkout'
alias gp='git push'

alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gst='git stash'
alias gl='git log'
alias glO='git log --oneline'
alias glG='git log --oneline --graph'

alias ..='cd ..'
alias ...='cd ../..'

alias d='docker'
alias di='docker images'

alias dc='docker-compose'

alias CP='pwd | C'
alias PP='cd `V`'

# pacman -S lsd
# https://github.com/lsd-rs/lsd

alias ls='lsd --group-directories-first'
alias ll='ls -lXF --group-directories-first'
alias lla='ls -lAXtF --group-directories-first'

alias c='clear'
alias suvi='sudoedit'
alias e='exit'

alias fman='compgen -c | fzf | xargs tldr'

alias fzf_file_current="fd --max-depth 1 --type f . | sed 's|^\./||' | fzf --preview 'bat --style=numbers --color=always {}' | xargs -I {} sh -c 'test -n \"{}\" && nvim \"{}\"'"
alias fzf_file_current_hidden="fd --max-depth 1 --type f --hidden . | sed 's|^\./||' | fzf --preview 'bat --style=numbers --color=always {}' | xargs -I {} sh -c 'test -n \"{}\" && nvim \"{}\"'"
alias fzf_file_recursive="fd --type f . | sed 's|^\./||' | fzf --preview 'bat --style=numbers --color=always {}' | xargs -I {} sh -c 'test -n \"{}\" && nvim \"{}\"'"
alias fzf_file_recursive_hidden="fd --type f --hidden . | sed 's|^\./||' | fzf --preview 'bat --style=numbers --color=always {}' | xargs -I {} sh -c 'test -n \"{}\" && nvim \"{}\"'"

alias ff='fzf_file_current'
alias ff.='fzf_file_current_hidden'
alias ffr='fzf_file_recursive'
alias ffr.='fzf_file_recursive_hidden'
alias ff.r='ffr.'

fzf_CD_home() {
  local dir
  dir=$(fd --type d . ~ | sed 's|^\./||' | fzf --header='Jump to location' --preview 'tree --gitignore -dC -L 3 {}' --preview-window=right:50%) && cd "$dir"
}
fzf_CD_home_hidden() {
  local dir
  dir=$(fd --hidden --type d . ~ | sed 's|^\./||' | fzf --header='Jump to location' --preview 'tree --gitignore -dC -L 3 {}' --preview-window=right:50%) && cd "$dir"
}
fzf_CD_current_recursive() {
  local dir
  dir=$(fd --type d . | sed 's|^\./||' | fzf --header='Jump to location' --preview 'tree --gitignore -dC -L 3 {}' --preview-window=right:50%) && cd "$dir"
}
fzf_CD_current_recursive_hidden() {
  local dir
  dir=$(fd --hidden --type d . | sed 's|^\./||' | fzf --header='Jump to location' --preview 'tree --gitignore -dC -L 3 {}' --preview-window=right:50%) && cd "$dir"
}
fzf_CD_current_relative() {
  local dir
  dir=$(fd --type d --max-depth 1 . | sed 's|^\./||' | fzf --header='Jump to location' --preview 'tree --gitignore -dC -L 3 {}' --preview-window=right:50%)
  if [ -n "$dir" ]; then
    cd "$dir" && if [ $(fd --type d --max-depth 1 --hidden --ignore-file .gitignore | wc -l) -gt 0 ]; then
      fzf_CD_current_relative
    fi
  fi
}
fzf_CD_current_relative_hidden() {
  local dir
  dir=$(fd --hidden --type d --max-depth 1 . | sed 's|^\./||' | fzf --header='Jump to location' --preview 'tree --gitignore -dC -L 3 {}' --preview-window=right:50%)
  if [ -n "$dir" ]; then
    cd "$dir" && if [ $(fd --type d --max-depth 1 --hidden --ignore-file .gitignore | wc -l) -gt 0 ]; then
      fzf_CD_current_relative_hidden
    fi
  fi
}

alias flh='fzf_CD_home'
alias flh.='fzf_CD_home_hidden'
alias fl.h='flh.'
alias fl='fzf_CD_current_relative'
alias fl.='fzf_CD_current_relative_hidden'
alias flr='fzf_CD_current_recursive'
alias flr.='fzf_CD_current_recursive_hidden'
alias fl.r='flr.'

export FZF_DEFAULT_OPTS="
  --bind 'ctrl-x:clear-query'
  --bind 'ctrl-j:jump'
  --bind 'ctrl-t:last'
  --bind 'ctrl-b:first'
  --bind 'ctrl-u:half-page-up'
  --bind 'ctrl-d:half-page-down'
  --bind 'alt-p:preview-half-page-up'
  --bind 'alt-n:preview-half-page-down'
"

alias f='echo "
  
  Hello, fzf!

        ff         fzf_file_current
        ff.        fzf_file_current_hidden
        ffr        fzf_file_recursive
        ffr.       
        ff.r       fzf_file_recursive_hidden
        
        fl         fzf_CD_current_(relative)
        fl.        fzf_CD_current_(relative)_hidden
        flr        fzf_CD_current_recursive
        flr.       
        fl.r       fzf_CD_current_recursive_hidden
        flh        fzf_CD_home
        flh.       
        fl.h       fzf_CD_home_hidden

--bind  ctrl-x     clear-query
--bind  ctrl-j     jump
--bind  ctrl-t     last
--bind  ctrl-b     first
--bind  ctrl-u     half-page-up
--bind  ctrl-d     half-page-down
--bind  alt-p      preview-half-page-up
--bind  alt-n      preview-half-page-down
"'

bind -x '"\C-l": clear'

alias browser='google-chrome'
google() {
    browser "https://www.google.com/search?q=$1"
}

# export PATH="/opt/flutter/bin:$PATH"
# export JAVA_HOME='/usr/lib/jvm/java-8-openjdk/jre'
# export PATH=$JAVA_HOME/bin:$PATH 
# export ANDROID_SDK_ROOT='/opt/android-sdk'
# export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools/
# export PATH=$PATH:$ANDROID_SDK_ROOT/tools/bin/
# export PATH=$PATH:$ANDROID_ROOT/emulator
# export PATH=$PATH:$ANDROID_SDK_ROOT/tools/

xhost +local:root > /dev/null 2>&1

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend
# show history datetime
HISTTIMEFORMAT='%F %T '
HISTCONTROL=ignoredups
#export EDITOR=/usr/bin/nvim
export SUDO_EDITOR=/usr/bin/nvim

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Install packages using yay (change to pacman/AUR helper of your choice)
yayinstall() {
  yay -Slq | fzf -q "$1" -m --preview 'yay -Si {1}'| xargs -ro yay -S 
}
# Remove installed packages (change to pacman/AUR helper of your choice)
yayremove() {
  yay -Qq | fzf -q "$1" -m --preview 'yay -Qi {1}' | xargs -ro yay -Rns 
}

# Install packages using yay (change to pacman/AUR helper of your choice)
pacinstall() {
  pacman -Slq | fzf -q "$1" -m --preview 'pacman -Si {1}'| xargs -ro pacman -S 
}
# Remove installed packages (change to pacman/AUR helper of your choice)
pacremove() {
  pacman -Qq | fzf -q "$1" -m --preview 'pacman -Qi {1}' | xargs -ro pacman -Rns 
}

bind '"\C-p": previous-history'
bind '"\C-n": next-history'

alias doc='cd /home/sy/Me/mkdocs/docs && vi .'
alias docup='git add . && git commit -m 'write' && git push && gh run watch'

alias lzd='lazydocker'
