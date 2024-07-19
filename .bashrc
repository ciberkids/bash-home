#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
archey
#alias ls='ls --color=auto'
#alias ll='ls -lah --color=auto'

#PS1='[\u@\h \W]\$ '
# Carica le funzioni
[ -e ~/.bash_functions ] && source ~/.bash_functions


# Carica gli alias
#[ -e ~/.bash_aliases ] && source ~/.bash_aliases
sourceIfExist ~/.bash_aliases

# Carica gli alias
#[ -e ~/.bash_aliases ] && source ~/.bash_aliases
sourceIfExist ~/.bash_exports


# Carica le shell options
sourceIfExist ~/.bash_options

# Fortune cow!! - non alla fine perché potrebbe chiamare_echoReturnValue
#which cowsay 1>/dev/null 2>/dev/null && cowsay `fortune`

# Prompt
export LESS='-R'
#export LESSOPEN='|bash ~/.melo/lessfilter.sh %s'

if [ "${HOME}" == "$(pwd)" ]; then
  gotoNewLastDir
fi

# Carica un file con impostazioni specifiche del pc in uso
#[ .e ~/.bash_specific ] && source ~/.bash_specific
sourceIfExist ~/.bash_specific

export PS1="\033[1m\033[31m\u\033[37m@\033[32m\h:\033[33m\w\033[0m\n \$ "
# Return value
export PROMPT_COMMAND=promptCommand

# Carica le variabili d'ambiente
sourceIfExist ~/.bash_variables

# Impostazione del titolo in base al comando eseguito
sourceIfExist ~/.bash_preexec
preexec_functions+=(dynamicTerminalTitle startTimer)

export LIBVIRT_DEFAULT_URI=qemu:///system


