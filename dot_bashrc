#
# ~/.bashrc
#


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
then
	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
	exec fish $LOGIN_OPTION
fi

if [ -f ~/.aliases ]; then
    . ~/.aliases
fi

if [ -f ~/.secret-aliases ]; then
    . ~/.secret-aliases
fi

export PATH=/home/nbkt/.local/bin:$PATH

eval "$(zoxide init bash)"

fastfetch
