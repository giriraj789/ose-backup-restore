osebackup_host_inventory_generator.py
#!/usr/bin/env python
### PREREQUISTE
#### 1. Should be executed from Ansible controller server/system or jump box.
##### 2. Python =<2.7.
###### 3. Ansible inventry server/system configured with password less ssh to all OSE master servers.
####### USE OF SCRIPT :::: <python> <scriptname> <arg1_osemaster1server_fqdn> <arg2_output_ansible_inventry_file>
########FOR EXAMPLE::: python osebackup_inventory_hostfile_generator.py osemaster1.example.com > ansible_hosts
 
import re
import os
import sys
import subprocess
from collections import OrderedDict

## Importing ETCD file from OSE master server, first server is always a preference and extracting OSE all master servers details
 
osemasterserver = sys.argv[1]
os.system("scp " + osemasterserver + ":/etc/etcd/etcd.conf etcd.conf")
 
etcdmasterdata = open("etcd.conf", "r")
linedata = ""
for line in etcdmasterdata:
    if line.startswith('ETCD_INITIAL_CLUSTER='):
     linedata = line
 
## Filter function for eliminating unwanted strings and characters from data
 
def string_cleanup(x, notwanted):
    for item in notwanted:
        x = re.sub(item,'', x)
    return x
 
## Applying Filter function
 
unwanted_list= ['ETCD_INITIAL_CLUSTER=','https://',':2380', '\n']
newline = string_cleanup(linedata, unwanted_list)
data = newline
data_list = re.split('=|,', data)
 
## Iteration based two separate lists for OSE hostnames and IP addressees
 
host_name = data_list[::2]
host_ip = data_list[1::2]
 
y = int(len(host_name))
 
## Iteration begins
 
ip = []
count = 0
while count < y:
ip.append("master"+str(count+1)+"_ip")
count = count + 1
 
host = []
count = 0
while count < y:
host.append("master" + str(count+1))
count = count + 1
 
## Dictionary for merging OSE hostnames and IP addresses lists
 
host_dict = {}
ip_dict = {}
host_dict = OrderedDict(zip(host, host_name))
ip_dict = OrderedDict(zip(ip, host_ip))
 
#######################################
# Creating Backup host inventory file #
#######################################
 
print "[OSEV3:children]\nmasters\ncontroller"
count = 0
master = "master"
while count < y:
print master+str(count+1)
count = count + 1
print ""
print "[OSEV3:vars]\nansible_ssh_user=root"
for (k, v), (i, j) in zip(host_dict.items(),ip_dict.items()):
   print str(k+'='+v)
   print str(i+'='+j)
print ""
print"[masters]"
for k,v in host_dict.items():
    print v
print ""
count = 0
while (count < y):
print "[master"+str(count+1)+"]"
print host_dict.values()[count]
count = count + 1
print ""
print"[controller]"
controllerhostname = os.uname()[1]
ci = subprocess.check_output(("hostname", "-i"))
controllerip = ci.strip('\n')
print str(controllerhostname+'='+controllerip)
###
try:
    os.remove("etcd.conf")
except OSError:
    pass
 
#######
# END #
#######
