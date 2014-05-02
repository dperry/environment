# .bash_profile

command_exists () {
    type "$1" &> /dev/null ;
}

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

#file to hold local stuff - does not get sync'd
#we do this after .bashrc so things in it can override .bashrc
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
export LESS=-X

#Fixes dodgy svn locale warnings on P1 systems
export LC_ALL=C

export PATH
unset USERNAME
unset SSH_AUTH_SOCK

if [ ! -f ~/.bash_nointro ]; then
if [ ! -f ~/.bash_shortintro ]; then

unamen=`uname -n`
unamer=`uname -r`
unamei=`uname -i`
release=`cat /etc/*release /etc/*version /etc/debian* 2>/dev/null | grep -E -m 1 --color=none "[a-z]"`
whob=`who -b|sed 's/system boot//'|sed 's/^[ \t]*//;s/[ \t]*$//'`
cpuname=`grep 'model name' /proc/cpuinfo -m 1|sed 's/model name\s:\s//'`
cpucount=`grep 'model name' /proc/cpuinfo|wc -l`

clear

echo -e "\E[1;4;34m$unamen:\E[m"
echo "$release $unamei - $unamer"
echo

echo -e "\E[1;4;34mUptime:\E[m (started @ $whob)"
uptime
echo

#end of bash_shortintro #1
fi

echo $unamen | grep fr3d >/dev/null 2>/dev/null
if [ $? -eq 0 ] || [ -f ~/.bash_longintro ]; then

echo -e "\E[1;4;34mProcessor:\E[m"
echo "${cpucount}x $cpuname"
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

grep -v 'lo\|sit' /proc/net/dev | awk ' { print $1 }' | grep '[0-9]*:' | sed 's/:[0-9]*//' | while read line
do
	/sbin/ifconfig $line | grep --color=none 'HWaddr\|inet addr'
	echo
done

echo -e "\E[1;4;34mRoutes:\E[m"
/sbin/route -n|grep -v Kernel|grep -v 169\.254|grep -v UH
echo

#end of grep for fr3d or bash_longintro file
fi

if [ ! -f ~/.bash_shortintro ]; then

echo -e "\E[1;4;34mLast Login:\E[m"
last -i -n 10 `whoami`|grep -v begins|grep -v 'still logged in'|grep `whoami` -m 1 --color=never
echo

echo -e "\E[1;4;34mConnected Users:\E[m"
who
echo

#end of bash_shortintro #2
fi

if command_exists screen ; then
	echo -e "\E[1;4;34mScreens:\E[m"
	screen -list
fi

#end of bash_nointro
fi
