#!/bin/bash

#set -x
cidr=$(yq e '.Resources.attributes| to_entries | map(.value) | .[1]' vpc.yml)
vpcName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' vpc.yml)
region=$(yq e '.Resources.attributes| to_entries | map(.value) | .[2]' vpc.yml)
tagy=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' vpc.yml))
tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' vpc.yml))


action=$1
#opFile=$2

if [[ $action == "VPC" ]]
then
    echo "Please enter the output file for infra details: " 
    read opFile
    #create new vpc
    aws ec2 create-vpc --cidr-block $cidr --region $region
    #Fetching VPCID of the created VPC
    newVpcId=$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpcName" --query "Vpcs[].VpcId" --output text)
    aws ec2 create-tags --resources $newVpcId --tags Key=Name,Value=$vpcName
    
    for vpcId in $newVpcId
    do
    echo "vpcId="$vpcId >> $opFile
        for ((i=0;i<${#tagy[@]};i++))
        do
            #echo $i
            echo "key: " ${tagy[i]}
            echo "value: " ${tagValue[i]}
            aws ec2 create-tags --resources $vpcId --tags Key=${tagy[i]},Value=${tagValue[i]}
        done
    done     
    #printing data to properties files
    echo "cidr="$cidr >> $opFile
    echo "name="$vpcName >> $opFile
    
    
elif [[ $action == "IGW" ]]
then
    echo "Please enter input file to take resource values from: "
    read ipFile
    echo "Please enter the output file to store resource structure details: " 
    read opFile
    echo "Please enter the Vars file: " 
    read varsFile
    source $varsFile
    echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    echo "THE VPC ID IS ________________________"$vpcId
    echo "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    #vars
    igwName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' $ipFile)
    tagKey=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' $ipFile))
    tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' $ipFile))
    
    aws ec2 create-internet-gateway --tag-specifications 'ResourceType=internet-gateway,Tags=[{Key=Name,Value='${igwName}'}]'

    #fetch igwId
    newIgwId=$(aws ec2 describe-internet-gateways  --filters "Name=tag:Name,Values=$igwName" --query "InternetGateways[].InternetGatewayId" --output text)

    for igwId in $newIgwId
    do
        for ((i=0;i<${#tagKey[@]};i++))
        do
            #echo $i
            echo "key: " ${tagKey[i]}
            echo "value: " ${tagValue[i]}
            aws ec2 create-tags --resources $igwId --tags Key=${tagy[i]},Value=${tagValue[i]}
        done
        #attach igw
        aws ec2 attach-internet-gateway --internet-gateway-id $igwId --vpc-id $vpcId
    done     
    #############################################################################################################
   # aws ec2 attach-internet-gateway --internet-gateway-id $igwId --vpc-id $vpcId
    #############################################################################################################
    # aws ec2 create-internet-gateway
elif [[ $action == "SUBNET" ]]
then
    echo "Please enter input file to take values from: "
    read ipFile
    echo "Please enter the output file to store resource structure details: " 
    read opFile
fi 
