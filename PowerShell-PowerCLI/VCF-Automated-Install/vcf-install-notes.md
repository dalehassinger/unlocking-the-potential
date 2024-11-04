###### Commands to monitor install
tail -f -n 45 /var/log/vmware/vcf/bringup/vcf-bringup.log

less /var/log/vmware/vcf/bringup/vcf-bringup.log




# Only require a single ESXi Host
echo "bringup.mgmt.cluster.minimum.size=1" >> /etc/vmware/vcf/bringup/application.properties

# check to make sure added
cat /etc/vmware/vcf/bringup/application.properties

# restart the service
systemctl restart vcf-bringup.service



# Add to json file in "clusterSpec":
"hostFailuresToTolerate": 0



# Checklist
**Promiscuous mode and Forged transmits needs to be set to accept on the switch of the ESXi Host**
change to use a single vm for SDDC
Restart builder service
Be Patient. At one pint nothing changed in log for 10 - 15 minutes

