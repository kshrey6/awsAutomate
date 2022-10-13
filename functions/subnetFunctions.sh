#!/bin/bash

function createSubnet(){
    defFile=$1
    propFile=$2

    echo "Please enter preReq files to fetch VpcId"
    read preReq
    source PROPERTIES/$preReq
    ########################### VARS ###########################
    subnetName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' $defFile)
    cidr=$(yq e '.Resources.attributes| to_entries | map(.value) | .[1]' $defFile)
    az=$(yq e '.Resources.attributes| to_entries | map(.value) | .[2]' $defFile)
    tagKey=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' $defFile))
    tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' $defFile))
    ########################### VARS ###########################
    echo "CIDR="$cidr > PROPERTIES/$propFile
    echo "subnetName="$subnetName >> PROPERTIES/$propFile
    #Create Subnet
    aws ec2 create-subnet --vpc-id $vpcId --cidr-block $cidr --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$subnetName}]"
    #Generate SubnetId
    newSubnetId=$(aws ec2 describe-subnets --filters "Name=cidr,Values=$cidr" --query "Subnets[].SubnetId" --output text)
    
    for subnetId in $newSubnetId
    do
        echo "subnetId="$subnetId >> PROPERTIES/$propFile
        for ((i=0;i<${#tagKey[@]};i++))
        do
            addTags ${tagKey[i]} ${tagValue[i]} $subnetId           
        done

    done         
}

function addTags() {
    tagKey=$1
    tagValue=$2
    SUBID=$3
        echo "key: " $tagKey
        echo "value: " $tagValue
      aws ec2 create-tags --resources $SUBID --tags Key=$tagKey,Value=$tagValue
}