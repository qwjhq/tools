#!/bin/bash

source ./comm.sh

if [ ! -f ${CPU_TASK_FILE} ]
then
  echo "task_file not exist !"
  exit
fi

pid_array=()
cpu_num=$(grep processor /proc/cpuinfo |wc -l)

for i in $(seq ${cpu_num})
do
echo -ne "i=0;
while true
do
  i=i+1;
done" | nohup /bin/sh >> ${CURR_DIR}/cpu_consume_up.log 2>&1 &
    pid_array[${i}]=$! ;
done

for i in "${pid_array[@]}"; do
  echo $i >> ${CPU_TASK_FILE}
done
