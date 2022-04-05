#!/bin/bash
## before use, host network must set use macvlan bridge mode
nsName=macvlantest
vlanId=1100 # vlan's id
nsDev=mb1 # link name for macvlan, add to macvlan namespace
phyDev=bond0 # add macvlan card to phy card
nsIP=172.16.200.240
ipSubnet=24 # "72.16.200.240/24"
testPingIP="172.16.200.1 172.16.200.2 172.16.200.3 172.17.200.2" # gateway, hostip, same subnet with host other ip, need access forward route hostip


function execCmd() {
  ip netns exec ${nsName} ip link $1
}

function cleanExitNs() {
  echo "clear ${nsName} netns ..."
  execCmd "del ${nsDev}.${vlanId}"
  execCmd "del ${nsDev}"
  ip netns delete ${nsName}
}

function createNs() {
  echo "create ${nsName} netns ..."
  ip netns add ${nsName}
  ip link add ${nsDev} link ${phyDev} type macvlan mode bridge
  ip link set dev ${nsDev} netns ${nsName}
  execCmd "set ${nsDev} up"
  execCmd "set lo up"
  execCmd "add ${nsDev}.${vlanId} link ${nsDev} type vlan id ${vlanId}"
  execCmd "set ${nsDev}.${vlanId} up"
}

function testPing() {
  echo -e "\n\n"
  echo "test ping $1 ip ..."
  ip netns exec ${nsName} ping ${1} -c 4
}


echo "check ${nsName} netns exits ..."
ip netns ls |grep ${nsName}
if [ $? == 0 ]
then
  cleanExitNs
fi

createNs
echo "set netns ip ${nsIP}"
ip netns exec ${nsName} ip addr add ${nsIP}/${ipSubnet} dev ${nsDev}.${vlanId}
for ip in $(echo ${testPingIP})
do
  testPing ${ip}
done

