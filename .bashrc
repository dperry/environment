# .bashrc

# Don't do anything if we're a non-interactive shell
[ -z "$PS1" ] && return

# ALT+Left/Right
bind '"\e\e[C":forward-word'
bind '"\e\e[D":backward-word'

command_exists () {
    type "$1" &> /dev/null ;
}

truncatelog () {
	if [ -z $1 ] || [ ! -f $1 ]; then
		echo "First argument must be a file"
		return 1
	fi
	touch $1.trunctmp
	chown $(stat -c%u:%g $1) $1.trunctmp
	chmod $(stat -c%a $1) $1.trunctmp
	mv $1 $1.truncold && mv $1.trunctmp $1
	read -p "Delete old file (y/n)? " -n 1
	if [[ ! $REPLY =~ ^[Yy]$ ]]; then
		echo
		echo "$1 has been truncated; old file is now $1.truncold"
		return 0
	else
		echo
		echo "$1 has been truncated; old file has been deleted"
		rm -f $1.truncold
	fi
}

unixdev () {
	if [ -n $1 ] && [ ! -d $1 ] && [ ! -f $1 ]; then
		echo "No such file or directory '$1'."
		return 1
	elif [ -z $1 ]; then
		local MYPATH="./"
	else
		local MYPATH=$1
	fi
	chgrp -R UNIX-DEV $MYPATH
	chmod -R g+w $MYPATH
}

#http://stackoverflow.com/questions/394230/detect-the-os-from-a-bash-script
platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
	platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
	platform='freebsd'
fi

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias df='df -h'
alias cls='clear'

if [[ $platform == 'linux' ]]; then
	alias ls='ls -h --color=auto'
	alias ll='ls -lh --color=auto'
	alias la='ls -ah --color=auto'
	alias lr='ls -rh --color=auto'
	alias lla='ls -alh --color=auto'
	alias lal='ls -alh --color=auto'
elif [[ $platform == 'freebsd' ]]; then
	alias ls='ls -hG'
	alias ll='ls -lhG'
	alias la='ls -ahG'
	alias lr='ls -rhG'
	alias lla='ls -alhG'
	alias lal='ls -alhG'
fi

#don't do this for freebsd (Mac), since we use a GUI :)
if [[ $platform == 'linux' ]]; then
	tty=`tty | sed -r "s:(^/dev/|/?[0-9]{1,2}$)::g"`
	if [[ $tty == 'tty' ]]; then
		setterm -powersave off -blank 0 2>&1 >/dev/null
	fi
fi

alias grep='grep --color=auto'
alias nano='nano -w'
alias chmog='chmod'
alias px='ps x'
alias pa='ps ax'
alias pu='ps aux'
alias hg='history | grep '
alias top10='ps -eo pcpu,pid,user,args | sort -k 1 -r | head'
alias top10cpu='top10'
alias top10du='du -cms .[^.]*/ */ | sort -rn | head'
alias postfix-flush='/usr/sbin/postqueue -c /etc/postfix -f'
alias flush-postfix='postfix-flush'
alias fucking='sudo'
alias svnup='svn up --username=anonsvn --password=anonsvn'
alias sup='svnup'
alias svndiff='svn diff -x "-w --ignore-eol-style"'
alias sdiff='svndiff'
alias gpull='git pull'
alias gpush='git push'
alias push='gpush'
alias pull='gpull'
alias gdiff='git diff'
alias develop='git checkout develop'
alias svs='svn status'
alias yu='yum update'
alias yug='yum upgrade'
alias sb='sudo bash'


# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

distro="unknown"
distrobasic="unknown"
if [ -f /etc/redhat-release ]; then
	distro="RH-based"
	grep -q 'Red Hat Enterprise' /etc/redhat-release
	if [ $? -eq 0 ]; then
		distro="RHEL"
	fi
	grep -q 'CentOS' /etc/redhat-release
	if [ $? -eq 0 ]; then
		distro="CentOS"
	fi
	distrobasic=$distro
	distro="$distro `sed -r 's/.*([0-9])(\.[0-9]){1,2}.*/\1/' /etc/redhat-release`"
	bash_distro="\[\033[01;31m\][$distro]"
elif [ -f /etc/debian_version ]; then
	distro="Deb"
	distrobasic=$distro
	distro="$distro `sed -r 's/([0-9])(\.[0-9]{1,2}){1,2}/\1/' /etc/debian_version`"
	bash_distro="\[\033[01;34m\][$distro]"
	alias service="invoke-rc.d"
elif command_exists sw_vers ; then
	distro="Mac OS"
	distrobasic=$distro
	distro="$distro `sw_vers -productVersion`"
	bash_distro="\[\033[01;37m\][$distro]"
fi

if [[ `whoami` == "root" ]]; then
	promptsign="\[\033[01;31m\]#\[\033[00m\]"
else
	promptsign="$"
fi

function bash_prompt_command() {
	# How many characters of the $PWD should be kept
	local pwdmaxlen=40
	# Indicate that there has been dir truncation
	local trunc_symbol=".."
	local dir=${PWD##*/}
	pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))
	NEW_PWD=${PWD/#$HOME/\~}
	local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))
	if [ ${pwdoffset} -gt "0" ]; then
		NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
		NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
	fi
	export NEW_PWD
}

source ~/.git-prompt.sh
source ~/.git-completion.bash
GIT_PROMPT="\[\033[01;33m\]\$(__git_ps1)\[\033[00m\] "

#PROMPT_COMMAND='printf "\033]0;%s@%s:%s\007" "${USER}" "${HOSTNAME}" "${PWD/#$HOME/~}"'
PROMPT_COMMAND=bash_prompt_command
ESC='\[\ek\]\[\e\\\]'
TITLEBAR='\[\033]0;\u@${HOSTNAME}:${NEW_PWD}$(__git_ps1)\007\]'
PS1middle="\[\033[01;32m\]\u\[\033[01;31m\]@\[\033[01;32m\]\H\[\033[01;31m\]:\[\033[01;34m\]\w\[\033[00m\]"
PS1="${ESC}${bash_distro} ${TITLEBAR}${PS1middle}${GIT_PROMPT}${promptsign} "

export PS1

if command_exists nano ; then
	export VISUAL="nano -w"
	export EDITOR="nano -w"
fi

if command_exists screen ; then
	alias nscreen='screen -A -m -d -S'
	alias rscreen='screen -rx'
	alias ns='screen -A -m -d -S'
	alias rs='screen -rx'
fi

extract () {
	if [ -f $1 ] ; then
		case $1 in
			*.tar.bz2)   tar xjf $1        ;;
			*.tar.gz)    tar xzf $1     ;;
			*.bz2)       bunzip2 $1       ;;
			*.rar)       rar x $1     ;;
			*.gz)        gunzip $1     ;;
			*.tar)       tar xf $1        ;;
			*.tbz2)      tar xjf $1      ;;
			*.tgz)       tar xzf $1       ;;
			*.zip)       unzip $1     ;;
			*.Z)         uncompress $1  ;;
			*.7z)        7z x $1    ;;
			*)           echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}
