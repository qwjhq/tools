#!/bin/bash

source ./comm.sh

MEM_SIZE=$1

if [ ! -d ${MEM_TMPFS_DIR} ]
then
   mkdir ${MEM_TMPFS_DIR}
fi

mount -t tmpfs -o size=${MEM_SIZE} tmpfs ${MEM_TMPFS_DIR} >> ${CURR_DIR}/mem_up.log  2>&1
if [ $? == 0 ]
then
    for i in `seq 10`
    do
      dd if=/dev/zero of=${MEM_TMPFS_DIR}/test count=1 bs=${MEM_SIZE} >> ${CURR_DIR}/mem_up.log  2>&1
      if [ $? == 0 ]
      then
          rm -f ${MEM_TMPFS_DIR}/test
      fi
    done
else
    echo "mem_test.sh run mount tmpfs failed ..."
fi

