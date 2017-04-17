#OSE BACKUP AND RESTORATION PROCESS

#CLUSTER CONFIGURATION : 3 Master servers with Embedded ETCD

--Playbooks , executable scripts and files having cluster defined variables and are based on specific cluster environment. 
  
--All steps should be executed from Ansible configured jump-box server or a controller in Ansible terminology as under defined sequence.

#Backup–Phase 
Step1:
Cluster Backup 

$ansible-playbook -i hosts playbooks/backup_cluster.yaml

Step2: (Cautionary)
Importing a copy of cluster backup data on a jump box server 

$ansible-playbook -i hosts playbooks/import_backup.yaml

#Restoration-Phase 
Step1:
Cluster Restoration 

$ansible-playbook -i hosts playbooks/restore_cluster.yaml

Author : Giriraj Rajawat
Email: giriraj.singh.rajawat@citi.com 
