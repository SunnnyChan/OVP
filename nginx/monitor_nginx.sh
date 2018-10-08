#! /bin/bash -
##! @File    : monitor_nginx.sh
##! @Date    : 2016/02/29
##! @Author  : chenguang02@gmail.com
##! @Version : 1.0
##! @Todo    : 
##! @FileOut : 

OPENRESTY_ROOT=$(cd "$(dirname $0)/.." && pwd)
NGINX_HOME="${OPENRESTY_ROOT}/nginx"
NGINX_LOAD_SH="${NGINX_HOME}/load_nginx.sh"
NGINC_PID_FILE="${NGINX_HOME}/var/nginx.pid"

MONITOR_PID="${NGINX_HOME}/var/mon_nginx.pid"
echo $$ > ${MONITOR_PID}

while true 
do
    if  ! [ -f  ${NGINC_PID_FILE} ] 
    then
        sh "$NGINX_LOAD_SH" start
    fi
    sleep 1
done

##! vim: ts=4 sw=4 sts=4 tw=100 ft=sh 
