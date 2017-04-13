#!/bin/bash
if egrep -q ETCD_INITIAL_CLUSTER_STATE=new /etc/etcd/etcd.conf; then
sed -i -e "s/ETCD_INITIAL_CLUSTER_STATE=new/ETCD_INITIAL_CLUSTER_STATE=existing/g" /etc/etcd/etcd.conf
else
exit 
fi
