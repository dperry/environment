# .bash_profile

# Source the gui and shell profile
if [ -f ~/.profile ]; then
    . ~/.profile
fi

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# File to hold local stuff
# we load this after .bashrc so things in it can override .bashrc
if [ -f ~/.bash_local ]; then
	. ~/.bash_local
fi

shopt -s histappend
shopt -s cmdhist
shopt -s histreedit
shopt -s cdspell
shopt -s checkwinsize

# User specific environment and startup programs
PATH=$PATH:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$HOME/bin
export HISTCONTROL=ignoredups:erasedups
export HISTTIMEFORMAT='%F %T '
export HISTFILESIZE=10000
export HISTSIZE=10000
export HISTIGNORE="ls:ll:la:lal:pwd:exit:clear:history"
export LESS="-erX"
#Fixes dodgy svn locale warnings on some systems
export LC_ALL=C
export PATH
unset USERNAME
unset SSH_AUTH_SOCK

if [ ! -f ~/.bash_nointro ]; then
	
	if [ ! -f ~/.bash_shortintro ]; then
		
		whob=`who -b|sed 's/system boot//'|sed 's/^[ \t]*//;s/[ \t]*$//'`
		cpuname=`grep 'model name' /proc/cpuinfo -m 1|sed 's/model name\s:\s//'`
		cpucount=`grep 'model name' /proc/cpuinfo|wc -l`

		clear

		echo -e "\E[1;4;34m`uname -n`:\E[m"
		echo "$distro `uname -i` - `uname -r`"
		echo

		echo -e "\E[1;4;34mUptime:\E[m (started @ $whob)"
		uptime
		echo

	fi
	
	if [ $distro == 'Arch' ] || [ -f ~/.bash_longintro ]; then

		echo -e "\E[1;4;34mProcessor:\E[m"
		echo "${cpucount}x$cpuname"
		if command_exists iostat ; then
			iostat -c|grep -v Linux
		fi

		echo -e "\E[1;4;34mMemory:\E[m (in MB)"
		free -m
		echo

		echo -e "\E[1;4;34mMounts:\E[m"
		df -h -x tmpfs
		echo

		echo -e "\E[1;4;34mEthernet:\E[m"
		# TODO Fix this
		grep -v 'lo\|sit' /proc/net/dev | awk ' { print $1 }' | grep --color=none '[0-9]*:' | while read line
		do
			ifconfig $line: | grep --color=none 'HWaddr\|inet addr'
			echo
		done

		echo -e "\E[1;4;34mRoutes:\E[m"
		/sbin/route -n|grep -v Kernel|grep -v 169\.254|grep -v UH
		echo

	fi

	if [ ! -f ~/.bash_shortintro ]; then

		echo -e "\E[1;4;34mLast Login:\E[m"
		last -i -n 10 `whoami`|grep -v begins|grep -v 'still logged in'|grep `whoami` -m 1 --color=never
		echo

		echo -e "\E[1;4;34mConnected Users:\E[m"
		who
		echo

		if command_exists screen ; then
			echo -e "\E[1;4;34mScreens:\E[m"
			screen -list
		fi

	fi

fi
