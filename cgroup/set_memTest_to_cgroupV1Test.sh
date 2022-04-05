#!/bin/bash

source ./comm.sh
source ./cgroup_v1.sh

cgroup_create  ${MEM_CGROUP_DIR}
sh mem_test.sh 100M &

for i in `seq 1 3`
do
  pid=$(pgrep -f mem_test.sh)
  if [ -z "${pid}" ]
  then
    echo "wait get mem_test.sh pid again ..."
    continue
  else
    echo "get mem_test.sh pid is ${pid}"
    echo "${pid}" > ${MEM_TASK_FILE}
    break
  fi
done

function get_mem_stat() {
  for i in `seq 1 5`
  do
    pgrep -f mem_test.sh > /dev/null 2>&1
    if [ "$?" != 0 ]
    then
       echo "mem_test.sh is oom!"
       break
    else
      echo "mem_test.sh is running in file task is $(cat ${MEM_TASK_FILE}|tr '\n' ' ') cgroup memory usage is $(cat ${MEM_USAGE_FILE})"
      sleep 3
      continue
    fi
  done
}

echo "............................................................Use 10MB ............................................................"
get_mem_stat
echo "get out of memory from /var/log/messages"
grep 'cgroup out of memory|cgroup_v1_test' /var/log/messages
mem_clean