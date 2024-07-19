function _echoReturnValue() {
  r=$?
  if [ $r != 0 ]; then
#    echo -ne "\033[1m\033[34m"
#    printf '%*s%s' `tput cols`  ":)"
#    echo -e "\033[0m"
#  else
    echo -ne "\033[1m\033[31m"
    printf '%*s%s' `tput cols` "$r :("
    echo -e "\033[0m"
  fi
}

function setCompilerPrompt() {
  export PS1="\033[1m\033[31m\u\033[37m@\033[32m\h:\033[33m\w\033[0m\n \$ "
}

function setNormalPrompt() {
  echo -e "\033[0m"
  export PS1="\u@\h:\w \$ "
}

function sourceIfExist() {
  [ -e $1 ] && source $1
}

function setNewLastDir() {
  echo `pwd` > /tmp/${USER}_last_dir
}

function gotoNewLastDir() {
  local dirfile=/tmp/${USER}_last_dir
  [ -e  ${dirfile} ] && [ -d "$(cat ${dirfile})" ] && cd "$(cat ${dirfile})"
}

function __cdReplacement() {
  if [ $# == 0 ]; then
    cd ~
  else
    cd "$*"
  fi
  setNewLastDir
}

function setTerminalTitle() {
  local title=`echo "${*}" | ~/.melo/pystrip.py`
  echo -en "\033];${title}\007"
}

function getLastCommand() {
  unset HISTFILE
  local temp=`history 1`
  temp=($temp)
  echo "${temp[1]}"
}

function dynamicTerminalTitle() {
  if [ "${TERM}" == "" ] || [ "${TERM}" == "linux" ]; then
   return
  fi

  #temp=($1)
  #last_command="${temp[*]}"
  local last_command=$1

  local actual_folder_path=`pwd`
  local actual_folder=`basename "${actual_folder_path}"`
  if [ -n "${SSH_CLIENT}" ]; then
    export __terminal_window_title="${last_command} (in ${USER}@`hostname -s`:${actual_folder})"
  else
    export __terminal_window_title="${last_command} (in ${actual_folder})"
  fi

  setTerminalTitle "${__terminal_window_title}"
}

function startTimer() {
  export __cmd_start_time=`date +%s%3N`
}

function humanTime() {
  local tmp_time=$1
  local days=`expr ${tmp_time} / 86400000`

  tmp_time=`expr ${tmp_time} - ${days} \* 86400000`
  local hours=`expr ${tmp_time} / 3600000`

  tmp_time=`expr ${tmp_time} - ${hours} \* 3600000`
  local minutes=`expr ${tmp_time} / 60000`

  tmp_time=`expr ${tmp_time} - ${minutes} \* 60000`
  local seconds=`expr ${tmp_time} / 1000`

  [ ${days} != 0    ] && echo -n "${days}d "
  [ ${hours} != 0   ] && echo -n "${hours}h "
  [ ${minutes} != 0 ] && echo -n "${minutes}m "
  echo -n "${seconds}s"
}

function printElapsedTime() {
  if [ -n "${__cmd_start_time}" ]; then
    local delta_time=$(expr $(date +%s%3N) - ${__cmd_start_time})
    __cmd_start_time=
    if [ ${delta_time} -gt 10000 ]; then
      local fp_delta_time=`expr ${delta_time} / 1000`.`printf "%03d" $(expr ${delta_time} % 1000)`
      echo -n "Command executed in ${fp_delta_time} s"
      if [ ${delta_time} -gt 60000 ]; then
        echo -n " ("
        humanTime ${delta_time}
        echo ")"
      else
        echo
      fi
    fi
  fi
}

function promptCommand() {
  _echoReturnValue
  [ -n "${__terminal_window_title}" ] && setTerminalTitle "* ${__terminal_window_title}"
  printElapsedTime
}

function shm() {
  __cdReplacement /dev/shm
  if [ -n "$*" ]; then
    local dname=`dirname $*`
    mkdir -p ${dname}
    __cdReplacement ${dname}
    if [ -n "${EDITOR+x}" ]; then
      ${EDITOR} `basename $*`
    else
      vi `basename $*`
    fi
  fi
}

function mtop() {
  local pid=(`pidof $1`)
  top -H -p ${pid[0]}
}

function addfav() {
  local this_dir=`pwd`
  if [ -e ${FAVDIRFILE} ]; then
    local line
    while read line; do
      local dirname=`echo ${line} | awk 'BEGIN{FS=";"}{print $1}'`
      if [ "${this_dir}" == "${dirname}" ]; then
        echo "${this_dir} is already in favourite."
        return;
      fi
    done < ${FAVDIRFILE}
  fi

  echo "${this_dir};$(date);$(hostname -s);${*}" >> ${FAVDIRFILE}
}

function favdir() {
  if [ -e ${FAVDIRFILE} ]; then
    if [ -z "$1" ]; then
      local count=1
      local line
      while read line; do
        echo -n "${count} - "
        echo ${line} | awk 'BEGIN{FS=";"}{printf("%s:%s - %s: %s\n", $3, $1, $2, $4)}'
        let '++count'
      done < ${FAVDIRFILE}
    else
      local count=1
      local line
      while read line; do
        if [ "$1" == "${count}" ]; then
          local dirname=`echo ${line} | awk 'BEGIN{FS=";"}{print $1}'`
          cd "${dirname}"
          return;
        fi
        let '++count'
      done < ${FAVDIRFILE}
      echo "Not found"
    fi
  else
    echo "No favourite directories set"
  fi
}

function findMovie {
 find /mnt/MovieAndTvShows/Movies/ -iname "*$1*"
}

function findNewMovie() {
 echo "days backwards $1..."
  if [ 'n' == "$2" ]; then
    find /mnt/MovieAndTvShows/Movies/ -type f -mtime -$1 -exec basename {} \;
  else
    find /mnt/MovieAndTvShows/Movies/ -type f -mtime -$1 -exec echo {} \;
  fi
}


function recreatePlex() {
echo "pulling latest image of Plex"
docker pull plexinc/pms-docker

echo "retriving the dangling images id"
toRemove=$(docker images -q plexinc/pms-docker  -f "dangling=true")



echo "stoping current container"
docker stop plex
echo "removing container"
docker rm plex

echo "removing the image"
docker rmi $toRemove
echo "restarting plex with the new image..."
docker run -d --name plex --restart unless-stopped -p 32400:32400/tcp -p 3005:3005/tcp -p 8324:8324/tcp -p 32469:32469/tcp -p 1900:1900/udp -p 32410:32410/udp -p 32412:32412/udp -p 32413:32413/udp -p 32414:32414/udp -e TZ=/etc/localtime -e PLEX_CLAIM="claim-DDFAqz93FQXQMfiW1pqy" -e ADVERTISE_IP="http://$( ip addr show  enp6s0 | grep -Po 'inet \K[\d.]+'):32400/" -h optimusprime -v /mnt/data/docker_persistent/plex-data:/config -v /mnt/MovieAndTvShows/TvShows:/data/tvshows -v /mnt/MovieAndTvShows/Movies:/data/movies -v '/mnt/data/Matteo And Manu/Pictures':/data/photos -v /mnt/data/docker_persistent/plex-data/transcoding:/transcode plexinc/pms-docker

echo "done"
}

function movefile () {
  find . -iname "$1*" -exec rsync -avh --progress --remove-source-files {} /mnt/MovieAndTvShows/ToFix/ \;
}

function moveMovieToCopy () {
  find /mnt/downloads/toCopy/ -iname "*.mkv" -exec rsync -avh --progress --remove-source-files {} /mnt/MovieAndTvShows/ToFix/ \;
}

function mvWithVersion() {
  VERSION_CONTROL=numbered mv -b -v /mnt/downloads/toCopy/* -t /mnt/MovieAndTvShows/ToFix/

}

function hdlist(){
  find -L /sys/bus/pci/devices/*/ata*/host*/target* -maxdepth 3 -name "sd*" 2>/dev/null |egrep block |egrep --colour '(ata[0-9]*)|(sd.*)' ;
}


function systemctl_restart {
    sudo systemctl restart "$1"
}

function systemctl_status {
    sudo systemctl status "$1"
}

echo "functions loaded"

