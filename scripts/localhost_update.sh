#!/bin/bash
set -e
 
# Validating & Assigning "$ETCD_HOSTNAME" variable value
 
ETCD1=$(awk '/Subject: CN=/ {print $2; exit}' /etc/etcd/peer.crt | sed -e "s/CN=//g")
ETCD2=$(awk '/ETCD_NAME/ {print $1; exit}' /etc/etcd/etcd.conf | sed "s/ETCD_NAME=//g")
 
if [ $ETCD1 == $ETCD2 ];then
export ETCD_HOSTNAME=$ETCD1
else echo "ERROR: Dissimilarity in between ETCDHOSTNAME"
fi
 
# ENV
 
file_mem=/tmp/mem
file_health=/tmp/cluster_health
 
# Storing randomly generated member ID of first ETCD master cluster server to “/tmp/mem” file
 
etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$ETCD_HOSTNAME:2379 member list | awk '{print$1; exit}'| sed -e "s/://g" > /tmp/mem
 
 
# Parsing "/tmp/mem" file generated in last step & assigning filtered value to "$member" variable
 
export member=$(etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$ETCD_HOSTNAME:2379 member list | awk '{print$1; exit}'| sed -e "s/://g")
 
# By default first member updated as local host ; Hence this step validate; update ETCD master with hostname and IP; Removes default local host parameter
 
if [ $member = `cat $file_mem` ]; then
etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$ETCD_HOSTNAME:2379 member update $member https://$(hostname -i):2380
else echo "ERROR : Member & file_mem data is dissimilar"
fi
 
# Passing cluster health status to "/tmp/cluster_health" file
 
etcdctl --cert-file /etc/etcd/peer.crt --key-file /etc/etcd/peer.key --ca-file /etc/etcd/ca.crt -C https://$ETCD_HOSTNAME:2379 cluster-health | grep ^cluster  > /tmp/cluster_health
 
# Validating CLUSTER HEALTH
 
if egrep -q 'cluster is healthy' $file_health ;
then echo "cluster is healthy"
echo "ERROR cluster has some initialization issue , Check etcd logs via command 'journalctl -f -t etcd'"
fi
 
############################
## LOCAL HOST UPDATE OVER ##
############################

 
