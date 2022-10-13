#!/bin/bash

function createVPC() {
    defFile=$1
    propFile=$2
    ########################### VARS ###########################
    cidr=$(yq e '.Resources.attributes| to_entries | map(.value) | .[1]' $defFile)
    vpcName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' $defFile)
    region=$(yq e '.Resources.attributes| to_entries | map(.value) | .[2]' $defFile)
    tagKey=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' $defFile))
    tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' $defFile))
    ########################### VARS ###########################
    #printing data to properties files
    echo "cidr="$cidr > PROPERTIES/$propFile
    echo "name="$vpcName >> PROPERTIES/$propFile
    #create new vpc
    aws ec2 create-vpc --cidr-block $cidr --region $region --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value='${vpcName}'}]'
    #Fetching VPCID of the created VPC
    newVpcId=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpcName" --query "Vpcs[].VpcId" --output text)
    for vpcId in $newVpcId
    do
    echo "vpcId="$vpcId >> PROPERTIES/$propFile
        for ((i=0;i<${#tagKey[@]};i++))
        do
            addvpcTags ${tagKey[i]} ${tagValue[i]} "$vpcId"
        done
    done     
    
}

function addvpcTags() {
    tagKey=$1
    tagValue=$2
    VPCId=$3
        echo "key: " $tagKey
        echo "value: " $tagValue
    echo $VPCId
      aws ec2 create-tags --resources "$VPCId" --tags Key=$tagKey,Value=$tagValue
}