#!/bin/bash
set -e
file_mem=/tmp/mem
file_health=/tmp/cluster_health
etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$(hostname):2379 member list | awk '{print$1; exit}'| sed -e "s/://g" > /tmp/mem
export member=$(etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$(hostname):2379 member list | awk '{print$1; exit}'| sed -e "s/://g")
if [ $member = `cat $file_mem` ]; then
etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$(hostname):2379 member update $member https://$(hostname -i):2380
else exit
fi
etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$(hostname):2379 cluster-health | grep ^cluster  > /tmp/cluster_health
if egrep -q cluster is healthy $file_health ;
then echo "cluster is healthy"
else exit
fi

