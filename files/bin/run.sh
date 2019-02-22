#!/bin/sh
# PURPOSE: simple wrapper script as docker entrypoint

# -- auto: path variables
scriptSelf=$0;
scriptName=$(basename $scriptSelf)
scriptCallDir=$(dirname $scriptSelf)
scriptFullDir=$(cd $scriptCallDir;echo $PWD)
scriptFullPath=$scriptFullDir/$scriptName;
scriptParentDir=$(dirname $scriptFullDir)
# -- /auto: path variables


# -- setup signal handling
# initialisation tasks
set -e
pid=0
pids=""

# HUP/USR1 actions
handler_usr1(){
  echo "[i] --- TOP of USR HANDLER ---"
  echo "[i] --- END of USR STATUS ---"
}

# TERM/QUIT/INT actions
handler_term(){
  echo "[i] --- TOP of SHUTDOWN HANDLER ---"
  if [[ ${pid} -ne 0 ]]; then
    for daemon_pid in ${pids}
    do
      pidname=$(pgrep -als0|grep "^${daemon_pid}"|awk '{print $2}')
      echo "[>] killing process [${pidname}] with pid ${daemon_pid}"
      kill -SIGTERM "${daemon_pid}"
      wait "${daemon_pid}"
    done
  fi
  echo "[i] --- END of SHUTDOWN HANDLER ---"
  exit 143; # 128 + 15 -- SIGTERM
}
# register handlers
trap 'kill ${!}; handler_usr1' SIGUSR1 SIGHUP
trap 'kill ${!}; handler_term' SIGTERM SIGQUIT SIGINT

# starting daemons
start_daemon(){
  # start in background
  exec "$@" &
  # get command pid
  pid="$!"
  pids="${pids} ${pid}"
  # show info
  echo "[>] command [${1}] started with pid ${pid}"
  echo "[>] running command pids: ${pids}"
}


# setup requirements
echo "[>] adding required hosts entries"
getent ahosts appserver1 || echo "127.0.0.2 appserver1" >>/etc/hosts
getent ahosts appserver2 || echo "127.0.0.2 appserver2" >>/etc/hosts


# starting services
echo "[>] starting services"
# -- service: nginx
nginx -g "pid /var/run/nginx.pid;"
# -- service: socks5
start_daemon socks5
# -- service: privoxy
start_daemon privoxy --pidfile /run/privoxy.pid --user privoxy /etc/privoxy/config


# if ran with arguments
if [ -n "${1}" ];then
  # pass all commands through
  exec "$@"
# if ran without arguments (DEFAULT)
else
  # wait forever
  echo "[>] starting endless loop"
  while true
  do
    tail -f /dev/null & wait ${!}
  done
fi


# eof
