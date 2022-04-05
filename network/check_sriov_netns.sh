#!/bin/bash

# get name from dir /sys/class/net/eth1|eth3/device/virtfnx/net/eth8
phyDev="eth1 eth3"
vlanId=1100 # vlan's id
nsName=sriovtest
nsDev=b0 # link name for macvlan, add to macvlan namespace
nsIP=172.16.200.240
ipSubnet=24 # "72.16.200.240/24"
testPingIP="172.16.200.1 172.16.200.2 172.16.200.3 172.17.200.2" # gateway, hostip, same subnet with host other ip, need access forward route hostip


function execCmd() {
  ip netns exec ${nsName} ip link $1
}


function checkSetVfNum() {
    if [ ! -f /sys/class/net/${1}/device/sriov_totalvfs ]
    then
      echo "no such file /sys/class/net/${1}/device/sriov_totalvfs"
      return
    fi
    totalNum=$(cat /sys/class/net/${1}/device/sriov_totalvfs)
    if [ ${totalNum} < 127 ]
    then
      echo "net card ${1} total vf num less then 127 ..."
      return
    fi

    setNum=$(cat /sys/class/net/${1}/device/sriov_numvfs)
    if [ ${setNum} < 127 ]
    then
       echo 127 > /sys/class/net/${1}/device/sriov_numvfs
    fi
}

function cleanExitNs() {
  echo "clear ${nsName} netns ..."
  ip netns exec ${nsName} ln -s /proc/1/ns/net /var/run/netns
  for ethVf in $(echo $1)
  do
    execCmd "set dev ${ethVf} netns net"
  done
  execCmd "del ${nsDev}.${vlanId}"
  execCmd "del ${nsDev}"
  ip netns delete ${nsName}
}

function createNs() {
  echo "create ${nsName} netns ..."
  ip netns add ${nsName}
  for ethVf in $(echo $1)
  do
      ip link set dev ${ethVf} netns ${nsName}
  done
  execCmd "add ${nsDev} type bond miimon 100 mode 2 xmit_hash_policy 4"
  for ethVf in $(echo $1)
  do
        execCmd "set ${ethVf} down"
        execCmd "set ${ethVf} master ${nsDev}"
  done
  execCmd "set ${nsDev} up"
  execCmd "set lo up"
  execCmd "add link ${nsDev} name ${nsDev}.${vlanId} type vlan id ${vlanId}"
  execCmd "set ${nsDev}.${vlanId} up"
}

function testPing() {
  echo -e "\n\n"
  echo "test ping $1 ip ..."
  ip netns exec ${nsName} ping ${1} -c 4
}

echo "check and set card vf numbers ..."
vfNames=""
for netCard in $(echo ${phyDev})
do
  msg=$(checkSetVfNum ${netCard})
  if [ "${msg}" != "" ]
  then
    exit
  fi
  vfNames="${vfNames} $(ls /sys/class/net/${netCard}/device/virtfn0/net/)"
  if [ "${vfNames}" == "" ]
  then
    echo "get net card $1 virtfn0 vf is null"
    exit
  fi
done

echo "check ${nsName} netns exits ..."
ip netns ls |grep ${nsName}
if [ $? == 0 ]
then
  cleanExitNs ${vfNames}
fi


createNs ${vfNames}
echo "set netns ip ${nsIP}"
ip netns exec ${nsName} ip addr add ${nsIP}/${ipSubnet} dev ${nsDev}.${vlanId}
for ip in $(echo ${testPingIP})
do
  testPing ${ip}
done

