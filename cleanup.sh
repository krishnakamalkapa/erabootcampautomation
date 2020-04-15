#!/bin/bash

echo " this script will Clean up the Network vlans and delete the Era Storage Container "

set -x
. ./env.conf

echo "==========Deleting the VM's=========================="

echo yes | acli vm.delete $VM_Prefix*

echo "########Deleting the Network vlans##################"

acli net.delete $ERA_STATIC_VLAN
acli net.delete $ERA_DHCP_VLAN

echo "==========Deleting Storage Container================"

ncli container remove name=$ERA_STORAGE_CONTAINER

echo "==========Cleanup Complete================"
