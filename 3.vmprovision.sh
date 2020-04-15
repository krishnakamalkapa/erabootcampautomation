#!/bin/bash
# 
# Description: 
#
# Usage: 
# ./3.vmprovision.sh $Databasetype(oracle12c,sql,all)
# 
#######################################################################
## User Configured Parameters ...

#--------------------------------------------------------------------------------
# Validate that two (and only two) command-line parameters have been submitted...
#--------------------------------------------------------------------------------
#set -x
. ./env.conf

log_file=/tmp/3.vmprovision.log

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

#num_sql_vms=3
for word in $(cat imagelist)
do
echo $word

imagevalidate=`acli image.get $word | grep -i image_state | awk -F '"' '{print $2}'`
        if [ "$imagevalidate" == "kActive" ];
        then
        echo "image$word present  " 
                else
        echo "image$word not present, exiting out"
                exit 0
        fi

done

echo "######################ALL Images present in the ImageService################"


oracle12c() {

oraclevmvalidate=`acli vm.list | grep -i "$VM_Prefix"_Oracle_12c |awk '{print $1}'`
if [ "$oraclevmvalidate" == "$VM_Prefix"_oracle_12c ];
then
       echo " Oracle VM with same name present"
        exit 0;
else

echo "################Oracle12cVM_Creation_INPROGRESS################"

exec_cmd "acli vm.create "$VM_Prefix"_Oracle_12c memory=16000M num_cores_per_vcpu=4 num_vcpus=1"
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_bootdisk.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_disk1.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_disk2.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_disk3.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_disk4.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_disk5.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_Oracle_12c clone_from_image="12c_disk6.qcow2""
exec_cmd "acli vm.nic_create "$VM_Prefix"_Oracle_12c network=vlan_"$SECONDARY_VLAN"_IPAM-DHCP"
exec_cmd "acli vm.on "$VM_Prefix"_Oracle_12c"

echo "################Oracle12cVM_Creation_COMPLETE##############"

fi

}

era() {

echo "################ERAVM_Creation_INPROGRESS################"

exec_cmd "acli vm.create "$VM_Prefix"_EraVM memory=16000M num_cores_per_vcpu=4 num_vcpus=1"
exec_cmd "acli vm.disk_create "$VM_Prefix"_EraVM clone_from_image="ERA1.2.1""
exec_cmd "acli vm.nic_create "$VM_Prefix"_EraVM network=vlan_"$SECONDARY_VLAN"_IPAM-DHCP"
exec_cmd "acli vm.on "$VM_Prefix"_EraVM"

echo "################ERAVM_Creation_Complete################"

}

mssql() {

sqlvmvalidate=`acli vm.list | grep -i "$VM_Prefix"_SQL|awk '{print $1}'`
if [ "$sqlvmvalidate" == "$VM_Prefix"_SQL ];
then
        echo "SQL VM with same name present"
        exit 0;
else

echo "################SQLVM_Creation_INPROGRESS################"

exec_cmd "acli vm.create "$VM_Prefix"_SQL memory=4096M num_cores_per_vcpu=4 num_vcpus=1"
exec_cmd "acli vm.disk_create "$VM_Prefix"_SQL clone_from_image="MSSQL_1.qcow2""
exec_cmd "acli vm.disk_create "$VM_Prefix"_SQL clone_from_image="MSSQL_2.qcow2""
exec_cmd "acli vm.nic_create "$VM_Prefix"_SQL network=vlan_"$SECONDARY_VLAN"_IPAM-DHCP"
exec_cmd "acli vm.on "$VM_Prefix"_SQL"

echo "################SQLVM_Creation_COMPLETE##################"

#echo "################SQLVM_Clone_Creation_INPROGRESS################"

#acli vm.clone "$VM_Prefix"_SQL_User[01..$num_sql_vms] clone_from_vm="$VM_Prefix"_SQL

#echo "################SQLVM_Clone_Creation_COMPLETE################"

fi

pdcvmvalidate=`acli vm.list | grep -i "$VM_Prefix"_PDC|awk '{print $1}'`
if [ "$pdcvmvalidate" == ""$VM_Prefix"_PDC" ];
then
        echo "PDC VM with same name present"
        exit 0;
        else

echo "################WINPDCVM_Creation_Inprogress##################"

exec_cmd "acli vm.create "$VM_Prefix"_PDC memory=4096M num_cores_per_vcpu=4 num_vcpus=1"
exec_cmd "acli vm.disk_create "$VM_Prefix"_PDC clone_from_image="MSSQL2016_PDC.qcow2""
exec_cmd "acli vm.nic_create "$VM_Prefix"_PDC network=vlan_"$SECONDARY_VLAN"_IPAM-DHCP"
exec_cmd "acli vm.on "$VM_Prefix"_PDC"

echo "################WINPDCVM_Creation_Complete##################"

fi

}

case "$1" in
         all)
            oracle12c
            mssql
            era 
            ;;
 
         oracle12c)
             oracle12c
             era
            ;;
         mssql)
             mssql
             era
            ;;
         *)
             echo "Usage: all|oracle12c|mssql|era"
             exit 1
esac
