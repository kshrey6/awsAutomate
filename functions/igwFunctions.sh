#!/bin/bash

function createIGW() {
    defFile=$1
    propFile=$2
    echo "Please enter preReq files for IGW"
    read preReq

    source PROPERTIES/$preReq

    ########################### VARS ###########################
    igwName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' $defFile)
    tagKey=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' $defFile))
    tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' $defFile))
    ########################### VARS ###########################
    echo "igwName=">PROPERTIES/$propFile
    #Create IGW
    aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value='${igwName}'}]'
    #fetch igwId
    newIgwId=$(aws ec2 describe-internet-gateways  --filters "Name=tag:Name,Values=$igwName" --query "InternetGateways[].InternetGatewayId" --output text)

    for igwId in $newIgwId
    do
        echo "IgwId="$igwId >> PROPERTIES/$propFile
        for ((i=0;i<${#tagKey[@]};i++))
        do
            addTags ${tagKey[i]} ${tagValue[i]} $igwId           
        done
        #attach igw
        aws ec2 attach-internet-gateway --internet-gateway-id $igwId --vpc-id $vpcId

    done         
}

function addTags() {
    tagKey=$1
    tagValue=$2
    IGWID=$3
        echo "key: " $tagKey
        echo "value: " $tagValue
      aws ec2 create-tags --resources $IGWID --tags Key=$tagKey,Value=$tagValue
}

# need to divert igw output properties to external file