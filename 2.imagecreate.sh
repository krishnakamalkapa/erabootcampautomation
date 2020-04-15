# Date: 2020-Jan-19
# Author: Krishna Kapa 
# 
# Description: 
#
# Usage: 
# ./2.imagecreate.sh 
# 
#######################################################################
. ./env.conf

if [[ "$CLUSTERID" =~ 'RTP' ]]; then
REPOSITORY="10.55.251.38"
echo REPOSITORY="$REPOSITORY"-RTP
else 
REPOSITORY="10.42.194.11"
echo REPOSITORY="$REPOSITORY"-PHX
fi

 for word in $(cat imagelist)
 do
 echo "----------$word----------"
 #set -x 
 #add a check to validate images
 if [[ "$word" =~ 'MSSQL' ]]; then
acli image.create $word source_url=http://$REPOSITORY/workshop_staging/era/SQLServer/$word container=$ERA_STORAGE_CONTAINER image_type=kDiskImage & 
 elif [[ "$word" =~ '12c' ]]; then
acli image.create $word source_url=http://$REPOSITORY/workshop_staging/era/oracle12cSIHA/$word container=$ERA_STORAGE_CONTAINER image_type=kDiskImage & 
 elif [[ "$word" =~ '19c' ]]; then
acli image.create $word source_url=http://$REPOSITORY/workshop_staging/era/oracle19cSIHA/$word container=$ERA_STORAGE_CONTAINER image_type=kDiskImage &
 
 elif [[ "$word" =~ 'ERA' ]]; then
 
acli image.create $word source_url=http://$REPOSITORY/workshop_staging/ERA-Server-build-1.2.1.qcow2 container=$ERA_STORAGE_CONTAINER image_type=kDiskImage &
 
 fi
 done

echo "#### Run acli image.list to verify if all the images are uploaded. ####"



