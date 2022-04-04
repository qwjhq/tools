#!/bin/bash

source ./comm.sh
source ./cgroup_v1.sh

cgroup_create ${CPU_CGROUP_DIR}
sh cpu_test.sh

function get_cpu_stat() {
    for i in `seq 1 3`
    do
        sleep 1
        echo "cpu_test.sh is running in file task is $(cat ${CPU_TASK_FILE}|tr '\n' ' ') cgroup cpu usage is $(cat ${CPU_STAT_FILE}|tr '\n' ' ')"
    done

    cat ${CPU_TASK_FILE}|tr '\n' ','|sed 's/,$//'|xargs -I A top -b -n 5  -p A
}

echo "............................................................Use 0.5 core............................................................"
get_cpu_stat


echo "............................................................Use 1 core............................................................"
cgroup_cpu_set 100000
get_cpu_stat

cpu_clean