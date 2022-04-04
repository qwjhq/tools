#!/bin/bash

# limit 100M for memory, 1 core for cpu
function create() {
    cgcreate -g memory,cpu:/cgroup_v1_test
    cgset -r memory.limit_in_bytes=10M cgroup_v1_test
    cgset -r cpu.cfs_quota_us=50000 cgroup_v1_test
    cgcreate -g blkio:/cgroup_v1_test
    echo  10M > /sys/fs/cgroup/memory/cgroup_v1_test/memory.memsw.limit_in_bytes
}

function cgroup_delete() {
    cgdelete -g  memory,cpu,blkio:/cgroup_v1_test
}

function cgroup_cpu_set() {
    if [ -z "$1" ]
    then
      echo "get cpu value failed ..."
      exit
    fi
    cgset -r cpu.cfs_quota_us=$1 cgroup_v1_test
}

function cgroup_mem_set() {
    if [ -z "$1" ]
    then
      echo "get mem value failed ..."
      exit
    fi
    cgset -r memory.limit_in_bytes=$1 cgroup_v1_test
}

function cgroup_create() {
    CGROUP_DIR=$1
    if [ -z "${CGROUP_DIR}" ]; then echo "cgroup dir is null... "; exit; fi
    if [ ! -d ${CGROUP_DIR} ]
    then
          create
    fi
}
