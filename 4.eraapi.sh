#!/bin/bash
# 

echo "##################################################"  >> /tmp/4.eraapi.log

#########################################################
#         NO CHANGES REQUIRED BELOW THIS POINT          #
#########################################################

#########################################################

. ./env.conf

log_file=/tmp/4.eraapi.log

echo $PRISM_IP
echo $PRISM_USER

if [ -n "$PRISM_IP" ]; then
        sed -i -e "s/.*ip_address.*/\"ip_address\": \"$PRISM_IP\"\,/" cluster.json
fi

echo "$VM_Prefix"
ERANETLIST=`acli net.list |grep DHCP | awk '{print $1}'`
echo $ERANETLIST
ERAIP=`acli net.list_vms $ERANETLIST | grep -i "$VM_Prefix"_EraVM | awk '{print $4}'`
echo $ERAIP
echo "executing the REST APIs"

baseurl=https://$ERAIP/era/v0.8
echo "======== Reset Era Initial Password============="

echo $baseurl
 
STATUS=$(curl -k -X POST $baseurl/auth/update -H 'Content-Type: application/json' -u $ERA_USER:"Nutanix/4u" -d '{ "password": "'"$ERA_PASSWORD"'" }')

if [[ $STATUS =~ success ]]; then
	echo "Password reset successful"

else	
	echo "Password change Failed $STATUS"
	exit 
fi


echo  "###========= Accept ELA  =========================="              


STATUS=$(curl -k -X  POST $baseurl/auth/validate -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD" -d '{ "eulaAccepted": true }')

if [[ $STATUS =~ success ]]; then
        echo "EULA Acceptance successful"
else
        echo "EULA Acceptance Failed $STATUS"
        exit
fi


echo "###========= Register Cluster =======================" 
 
STATUS=$(curl -k -X  POST $baseurl/clusters -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD" -d '{ "name": "EraCluster","description": "Era Cluster Description","ip": "'"$PRISM_IP"'","username": "'"$PRISM_USER"'","password": "'"$NEW_PE_ADMIN_PASSWORD"'","status": "UP","version": "v2","cloudType": "NTNX","properties": [{ "name": "ERA_STORAGE_CONTAINER","value": "'"$ERA_STORAGE_CONTAINER"'"}]}')

if [[ $STATUS =~ $PRISM_IP ]]; then
        echo "Cluster Registration Successful"
else
        echo "Cluster Registration Failed"
        exit
fi

sleep 10
echo "======== Get Cluster ID =========================="
 
STATUS=$(curl -k -X GET $baseurl/clusters -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD") 

if [[ $STATUS =~ UP ]]; then
        echo "Get Cluster Successful"
else
        echo "Get Cluster Failed"
        exit
fi

echo $STATUS > getcluster.out
getcluster=`python -c "import sys, json; f = open('getcluster.out') ; d = f.read() ; print(json.loads(d)[0]['id'])"`
echo $getcluster
rm getcluster.out

echo "========= Upload Cluster File =======================" 
 
STATUS=$(curl -k -X POST $baseurl/clusters/$getcluster/json -u $ERA_USER:"$ERA_PASSWORD" -H 'Content-Type: multipart/form-data' -F file="@"cluster.json)
 
if [[ $STATUS =~ $PRISM_IP ]]; then
        echo "Upload of Cluster configuration is Successful"
else
        echo "Upload of Cluster configuration Failed"
        exit
fi 


echo "========= Network Creation ========================="

echo "========= Network Static Creation ======================"

STATUS=$(curl -k -X  POST $baseurl/resources/networks -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD" -d '{"name":"'"$ERA_STATIC_VLAN"'","type":"Static","properties":[{"name":"VLAN_GATEWAY","value":"'"$SECONDARY_VLAN_DEF_GATEWAY"'"},{"name":"VLAN_PRIMARY_DNS","value":"'"$SECONDARY_VLAN_NAMESERVER"'"},{"name":"VLAN_SUBNET_MASK","value":"'"$SECONDARY_VLAN_SUBNETMASK"'"}]}')

if [[ $STATUS =~ $ERA_STATIC_VLAN ]]; then
        echo "Era Static Network Creation is Successful"
else
        echo "Era Static Network Creation Failed"
        exit
fi

echo "======== Get Created Network ID  =========================="

STATUS=$(curl -k -X  GET $baseurl/resources/networks -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD")

if [[ $STATUS =~ $ERA_STATIC_VLAN ]]; then
        echo "Get Static Network ID Successful"
else
        echo "Get Static Network ID  Failed"
        exit
fi

echo $STATUS > getnetworkid.out

getnetworkid=`python -c "import sys, json; f = open('getnetworkid.out') ; d = f.read() ; print(json.loads(d)[0]['id'])"`
echo $getnetworkid
rm getnetworkid.out

echo "========= Add Static IP Pool  =========================="

STATUS=$(curl -k -X  POST $baseurl/resources/networks/$getnetworkid/ip-pool -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD" -d '{"ipPools": [{"startIP": "'"$IP_STATIC_START"'","endIP": "'"$IP_STATIC_END"'"}]}')

if [[ $STATUS =~ $IP_STATIC_START ]]; then
        echo "Static IP Pool Configuration Successful"
else
        echo "Static IP Pool Configuration Failed"
        exit
fi

echo "========= Network DHCP Creation ========================="

STATUS=$(curl -k -X  POST $baseurl/resources/networks -H 'Content-Type: application/json' -u $ERA_USER:"$ERA_PASSWORD" -d '{"name": "'"$ERA_DHCP_VLAN"'","type": "DHCP"}')

if [[ $STATUS =~ $ERA_DHCP_VLAN ]]; then
        echo "DHCP Network Configuration Successful"
else
        echo "DHCP Network Configuration Failed"
        exit
fi

echo "========= Era Configuration Successful =========================="
