#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load global settings
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ -f  /etc/bash.bashrc ]; then
	. /etc/bash.bashrc
fi


archey

dir_for_bash-home="$HOME/git/bash-home"

#####
#PS1='[\u@\h \W]\$ '
#load functions 
for file in ${dir_for_bash-home}/bashRcFiles/bash_functions_to_import
[ -e ${dir_for_bash-home}/bashRcFiles/bash_mandatoryFunctions ] && source ${dir_for_bash-home}/bashRcFiles/bash_mandatoryFunctions


if type "sourceIfExist" > /dev/null 2>&1; then

  # load all functions  
  for file in ${dir_for_bash-home}/bashRcFiles/bash_functions_to_import/* do
    sourceIfExist ${file}
  done

  echo "The function 'sourceIfExist' exists."
  # load aliases
  sourceIfExist ${dir_for_bash-home}/bash_aliases
  
  # load exports
  sourceIfExist ${dir_for_bash-home}/bash_exports
  
  # load shell options
  sourceIfExist ${dir_for_bash-home}/bash_options


  # Fortune cow!! - not at the end it could call: _echoReturnValue
  #which cowsay 1>/dev/null 2>/dev/null && cowsay `fortune`

  if [ "${HOME}" == "$(pwd)" ]; then
    gotoNewLastDir
  fi

  # iload a specific file for the pc that i am using
  sourceIfExist  ${dir_for_bash-home}/bash_specific

  # Return value
  export PROMPT_COMMAND=promptCommand

  # Carica le variabili d'ambiente
  sourceIfExist ${dir_for_bash-home}/bash_variables

  # Impostazione del titolo in base al comando eseguito
  sourceIfExist ~/.bash_preexec
  preexec_functions+=(dynamicTerminalTitle startTimer)

else
  echo "Cannot source Files!!! aborting enhancement!"
fi


export PS1="\033[1m\033[31m\u\033[37m@\033[32m\h:\033[33m\w\033[0m\n \$ "




