#!/bin/bash -
OPENRESTY_ROOT=$(cd "$(dirname $0)/.." && pwd)
LOGS_PATH="${OPENRESTY_ROOT}/logs"
NGINX_HOME="${OPENRESTY_ROOT}/nginx"
NGINX_LOGS_PATH="${NGINX_HOME}/logs"
NGINX_BIN="${NGINX_HOME}/sbin/nginx"
PID_FILE="${NGINX_HOME}/var/nginx.pid"
MONITOR_SH="${NGINX_HOME}/monitor_nginx.sh"
MONITOR_PID="${NGINX_HOME}/var/mon_nginx.pid"
NGINX_LOGS_FILE="access_log error_log"

function start() {
    echo "Starting nginx:"
    [ -f ${PID_FILE} ] && { echo "$PID_FILE exist, nginx is already running"; return -1; }
    [ ! -d "${NGINX_LOGS_PATH}" ] && mkdir "${NGINX_LOGS_PATH}" 
    [ ! -d "${LOGS_PATH}" ] && mkdir "${LOGS_PATH}"
    for log_file in $NGINX_LOGS_FILE
    do
        [ ! -f "${NGINX_LOGS_PATH}/$log_file" ] && touch "${NGINX_LOGS_PATH}/$log_file"
        cd ${LOGS_PATH} && { rm -f "$log_file" ; ln -s "${NGINX_LOGS_PATH}/$log_file" "${log_file}"; } 
    done
    cd "${NGINX_HOME}/sbin" && limit -n 65535 $NGINX_BIN -p $NGINX_HOME >/dev/null 2>&1 &
    # start monitor script
    [ ! -f ${MONITOR_PID} ] && nohup /bin/bash "${MONITOR_SH}" >/dev/null 2>&1  &
    sleep 2
    if [ -f ${PID_FILE} ]
    then
        echo "Start OK"
        return 0
    else
        echo "Start Failed"
        return 1
    fi
}

function stop() {
    echo $"Stopping nginx:"
    [ ! -f ${PID_FILE} ] && { echo "$PID_FILE not exist, nginx not running"; return 0; }
    [ -f ${MONITOR_PID} ] && { kill "$(awk '{if(NR == 1){print $1; exit;}}' ${MONITOR_PID})" >/dev/null 2>&1; } && rm -f ${MONITOR_PID} 
    cd "${NGINX_HOME}/sbin" && { $NGINX_BIN -p $NGINX_HOME -s stop >/dev/null 2>&1; }
    sleep 2
    if [ -f ${PID_FILE} ]
    then
        echo $"Stop Failed"
        return 1
    else
        echo $"Stop OK"
        return 0
    fi
}

function reload(){
    echo $"Reloading nginx:"
    [ ! -f ${PID_FILE} ] && { echo "$PID_FILE not exist, nginx not running"; return 1; }
    cd "${NGINX_HOME}/sbin" && $NGINX_BIN -p $NGINX_HOME -s reload >/dev/null 2>&1
    local execRet=$?
    if [[ "${execRet}" == '0' ]]
    then
        echo "Reload OK"
        return 0
    else
        echo "Reload Failed"
        return 1
    fi
}

case "$1" in
  start)
      start
      ;;
  stop)
      stop
      ;;
  restart)
      stop
      start
      ;;
  reload)
      reload
      ;;
  *)
      echo "Usage: $0 {start|stop|restart|reload}"
      exit 1
esac
