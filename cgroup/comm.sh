#!/bin/bash

MEM_TMPFS_DIR="/tmp/memory"
MEM_TASK_FILE="/sys/fs/cgroup/memory/cgroup_v1_test/tasks"
MEM_USAGE_FILE="/sys/fs/cgroup/memory/cgroup_v1_test/memory.usage_in_bytes"
MEM_CGROUP_DIR="/sys/fs/cgroup/memory/cgroup_v1_test"
CPU_CGROUP_DIR="/sys/fs/cgroup/cpu/cgroup_v1_test"
CPU_TASK_FILE="/sys/fs/cgroup/cpu/cgroup_v1_test/tasks"
CPU_STAT_FILE="/sys/fs/cgroup/cpu/cgroup_v1_test/cpu.stat"
CURR_DIR=$(cd $(dirname $0); pwd)


function cpu_clean() {
    echo "begin clean cpu test ..."
    ps axu|grep '/bin/sh'|awk '{print $2}'|xargs kill -9 > /dev/null 2>&1
    if [ -d ${CPU_CGROUP_DIR} ]
    then
       cgroup_delete
    fi
    rm -f ./*.log
    echo "clean cpu test success ..."
}


function mem_clean() {
    echo "begin clean memory test ..."
    cat ${CURR_DIR}/mem_up.log
    rm -f ${CURR_DIR}/mem_up.log
    pgrep -f mem_test.sh | xargs kill -9 >/dev/null 2>&1
    ps aux|grep 'dd '|awk '{print $2}'|xargs kill -9 > /dev/null 2>&1
    if [ -d ${MEM_CGROUP_DIR} ]
    then
        cgroup_delete
    fi

    if [ -z "${MEM_TMPFS_DIR}" ]
    then
      echo "get MEM_TMPFS_DIR is null, clean memory test failed ..."
      exit
    fi

    for i in `seq 3`
    do
        if [ -d ${MEM_TMPFS_DIR} ]
        then
          umount ${MEM_TMPFS_DIR} >/dev/null 2>&1
          rm -rf ${MEM_TMPFS_DIR} > /dev/null 2>&1
        else
          break
        fi
    done
    echo "clean memory test success ..."
}
