#!/bin/bash
source functions/vpcFunctions.sh
source functions/igwFunctions.sh
source functions/subnetFunctions.sh
source functions/rtFunctions.sh
source functions/ec2Functions.sh
set -x

action=$1

function createResource() {
action=$1
defFile=$2
propFile=$3


case $action in 
    VPC)
    createVPC $defFile $propFile 
    ;;
    IGW)
    createIGW $defFile $propFile 
    ;;
    SUBNET)
    createSubnet $defFile $propFile 
    ;;
    ROUTETABLE)
    createRouteTable $defFile $propFile 
    ;;
    EC2)
    createEc2 $defFile $propFile
    ;;
esac
}

echo "Please Enter infra defination file:"
read ipFile
echo "Please enter the output file for infra details: " 
read opFile
createResource $action $ipFile $opFile
    