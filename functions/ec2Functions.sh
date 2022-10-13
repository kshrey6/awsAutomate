#!/bin/bash


function createEc2(){
    defFile=$1
    propFile=$2
########################### VARS ###########################
instanceName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' $defFile)
imgName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[1]' $defFile)
count=$(yq e '.Resources.attributes| to_entries | map(.value) | .[2]' $defFile)
instanceType=$(yq e '.Resources.attributes| to_entries | map(.value) | .[3]' $defFile)
keyName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[4]' $defFile)
subnetName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[5]' $defFile)

tagKey=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' $defFile))
tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' $defFile))
########################### VARS ###########################

echo "Please enter preReq files to fetch SubnetName:"
read preReq

source PROPERTIES/$preReq

imgId=$(getAmiId $imgName)
echo $imgId

subnetId=$(getSubnetId $subnetName)
echo $subnetId

createInstance $imgId $count $instanceType $keyName $subnetId
#aws ec2 run-instances --image-id ami-xxxxxxxx --count 1 --instance-type t2.micro --key-name MyKeyPair --subnet-id subnet-6e7f
}

function getAmiId() {
    imgName=$1
    aws ec2 describe-images --owners self --filters "Name=tag:type,Values=$imgName" --query 'Images[*].ImageId' --output text
}

function getSubnetId() {
    Name=$1
    aws ec2 describe-subnets --filters "Name=tag:type,Values=$Name" --query "Subnets[].SubnetId" --output text
}

function createInstance() {
    amiId=$1
    count=$2
    instype=$3
    key=$4
    aws ec2 run-instances --image-id $amiId --count $count --ins-type $instype --key-name $key --subnet-id 
}