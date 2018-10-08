#! /bin/bash -
##! @File    : install.sh
##! @Date    : 2016/02/29
##! @Author  : chenguang02@gmail.com
##! @Version : 1.0
##! @Todo    : 
##! @FileOut : 

OPENRESTY_ROOT=$(cd "$(dirname $0)/.." && pwd)
LUA_ROOT="${OPENRESTY_ROOT}/lua"
LIB_ROOT="${OPENRESTY_ROOT}/lib"
LUAJIT_ROOT="${LUA_ROOT}/luajit"

# create link for luajit library : libluajit-5.1.so.2
LUAJI_LIB_51="libluajit-5.1.so.2"
cd "${LIB_ROOT}"  && { rm -f ${LUAJI_LIB_51}; ln -s "${LUAJIT_ROOT}/lib/${LUAJI_LIB_51}" ${LUAJI_LIB_51}; }


