#!/bin/bash
######
# use NetworkManager manage network card
# exec command use: nohup set-macvlan-network.sh &
######
vlanId=$(ip a|grep @bond|awk -F'@' '{print $1}'|awk -F'.' '{print $2}')
function addMacvlan() {
  nmcli con |grep macvlan0.${vlanId}
  if [ $? == 0 ]
  then
    echo "add macvlan yet !"
    return
  fi
  nmcli con|grep macvlan0
  if [ $? == 0 ]
  then
    nmcli con del macvlan0
  fi
  nmcli con add type macvlan dev bond0 mode bridge tap yes ifname macvlan0 con-name macvlan0
  nmcli con modify macvlan0 ipv4.method shared
  nmcli con modify macvlan0 ipv6.method shared

  nmcli con add type vlan dev macvlan0 id ${vlanId} ifname macvlan0.${vlanId} con-name macvlan0.${vlanId}

  grep UUID /etc/sysconfig/network-scripts/ifcfg-macvlan0.${vlanId} > /tmp/netuuid
  \cp /etc/sysconfig/network-scripts/ifcfg-bond0.${vlanId} /etc/sysconfig/network-scripts/ifcfg-macvlan0.${vlanId}
  sed -i 's/bond0/macvlan0/g' /etc/sysconfig/network-scripts/ifcfg-macvlan0.${vlanId}
  sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-macvlan0.${vlanId}
  cat /tmp/netuuid >> /etc/sysconfig/network-scripts/ifcfg-macvlan0.${vlanId}
}

addMacvlan

ip route > /tmp/route.txt
while read line
do
  ip route del ${line}
done</tmp/route.txt

nmcli con|grep bond0.${vlanId}
if [ $? == 0 ]
then
  nmcli con del bond0.${vlanId}
fi
ip link|grep bond0.${vlanId}
if [ $? == 0 ]
then
  ip link del bond0.${vlanId}
fi

for i in `seq 5`
do
  ip route |grep macvlan0.${vlanId}
  if [ $? != 0 ]
  then
    systemctl restart NetworkManager
  fi
  sleep 2
done

