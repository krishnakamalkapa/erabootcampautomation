#!/bin/bash
# 
echo " this script will prep up the NTNX cluster "
echo "PLEASE  edit this script and populate all the variables correctly before proceesing"


. ./env.conf

log_file=/tmp/1.clusterprep.log

exec_cmd()
{
  echo ""   >> $log_file
  echo "---------------------------------------------------------" >> $log_file
  echo "$1" 
  $1        >> $log_file 2>&1
  return_code=$?
  if [ $return_code -ne 0 ] ; then
    echo "ERROR - $1 failed with $return_code"
    exit 1
  fi
}

# we equally divide the IP pool between DHCP and STATIC pools 
# the DHCP POOL is managed by IPAM
# the static Pool is managed within Era 
# a few IPS are best left unmanaged for misc use
#PLEASE ENTER ALL THE ABOVE ACCURATELY##
echo
echo
echo "if these are not entered , please CTRL-C to terminate and edit or" 
echo "or press any key to continue"
read bbb

## derived variables

DEFAULT_STORAGE_POOL=`ncli sp list |grep -i name | awk '{print $3}'`

SECONDARY_VLAN_NETWORK=`/home/nutanix/eraautomation/mask2cidr.sh $SECONDARY_VLAN_SUBNETMASK` # /25 or /26 network with 125/60 IPs for HPOC cluster by default

###$SECONDARY_VLAN_NETWORK="/25" # as an example manually entered
#### above mask could be entered manually after calculating"

IP_START=`echo $SECONDARY_IP_RANGE | awk -F "." '{print $4}' | awk -F "-" '{print $1}' `
IP_END=`echo $SECONDARY_IP_RANGE | awk -F "." '{print $4}' | awk -F "-" '{print $2}' `
echo "start          end"
echo $IP_START     $IP_END
TOTAL_IP=`expr $IP_END - $IP_START`
echo "totalip"
echo $TOTAL_IP

# Total DHCP IP's

TOTAL_DHCP_IP=`expr $TOTAL_IP / 2 ` # approx 60 /25 & 30 for /26

echo "TOTAL_DHCP_IP"
echo $TOTAL_DHCP_IP

IP_IPAM_DHCP_START=` echo $SECONDARY_IP_RANGE | awk -F "-" '{print $1}'`

echo "IP_IPAM_DHCP_START"
echo $IP_IPAM_DHCP_START

echo "IP_START  TOTAL_DHCP_IP"
echo $IP_START $TOTAL_DHCP_IP 
IP_IPAM_DHCP_END_IP=`expr $IP_START + $TOTAL_DHCP_IP `
echo $IP_IPAM_DHCP_END_IP
IP_IPAM_DHCP_ENDD=`echo $IP_IPAM_DHCP_START | awk -F "." '{print $1"."$2"."$3"."}'`
echo "IP_IPAM_DHCP_ENDD"
#echo $IP_IPAM_DHCP_ENDD
IP_IPAM_DHCP_END=`echo "$IP_IPAM_DHCP_ENDD""$IP_IPAM_DHCP_END_IP"`
echo $IP_IPAM_DHCP_END

IP_ST_START=`expr $IP_IPAM_DHCP_END_IP + 1`

echo "STATIC IP RANGE START is $IP_ST_START"

IP_STATIC_START=`echo "$IP_IPAM_DHCP_ENDD""$IP_ST_START"`
IP_STATIC_END=`echo "$IP_IPAM_DHCP_ENDD""$IP_END"`

echo "my era static start is $IP_STATIC_START"
echo "my era static end is $IP_STATIC_END"
echo "export IP_STATIC_START=$IP_STATIC_START" >> env.conf
echo "export IP_STATIC_END=$IP_STATIC_END" >> env.conf
echo "create vLANS"
echo
echo
echo "creating DHCP vLAN and adding IP pool"
echo
echo
#unhash below 2 lines to execute

exec_cmd "acli net.create  vlan_"$SECONDARY_VLAN"_IPAM-DHCP vlan=$SECONDARY_VLAN ip_config="$SECONDARY_VLAN_DEF_GATEWAY""$SECONDARY_VLAN_NETWORK""
exec_cmd "acli net.add_dhcp_pool vlan_"$SECONDARY_VLAN"_IPAM-DHCP start=$IP_IPAM_DHCP_START end=$IP_IPAM_DHCP_END"
exec_cmd "acli net.update_dhcp_dns vlan_"$SECONDARY_VLAN"_IPAM-DHCP servers=$SECONDARY_VLAN_NAMESERVER"

echo "creation of DHCP vLAN Successful"

echo
echo
echo "creating ERA STATIC vLAN "
echo
echo
#unhash below line to execute 
exec_cmd "acli net.create  "$ERA_STATIC_VLAN" vlan=$SECONDARY_VLAN"

echo
echo
echo "creation of ERA STATIC vLAN Successful"
echo
echo
echo "DEFAULT_STORAGE_POOL is $DEFAULT_STORAGE_POOL" 
#
echo "creating a new storage container for Era with compression ON and no Dedup"
##unhash below line to execute

exec_cmd "ncli ctr create name=$ERA_STORAGE_CONTAINER rf=2 sp-name=$DEFAULT_STORAGE_POOL enable-compression=true compression-delay=60"
echo
echo
echo "storage container $ERA_STORAGE_CONTAINER creation Successful"

echo "changing PE Admin Password to" $NEW_PE_ADMIN_PASSWORD

#unhash below line to execute
#exec_cmd "ncli -u admin -p "$CURRENT_PE_ADMIN_PASSWORD" user change-password current-password="$CURRENT_PE_ADMIN_PASSWORD" new-password="$NEW_PE_ADMIN_PASSWORD""
echo
echo
echo " PE admin password changed to $NEW_PE_ADMIN_PASSWORD Successful" 
echo
echo
echo "please proceed to run 2.imagecreate.sh"
##exit

echo
echo "Finished!"
echo
