#!/bin/bash

function createRouteTable(){
    defFile=$1
    propFile=$2

    echo "Please enter preReq files to fetch VpcId:"
    read preReq
    echo "Please enter preReq files to fetch SubnetId for Subnet Attachement:"
    read preReq2
    echo "Please enter preReq files to fetch IgwId for Subnet routes:"
    read preReq3
    
    source PROPERTIES/$preReq #for VpcId
    source PROPERTIES/$preReq2 #for SubnetId
    source PROPERTIES/$preReq3 #for IgwId
    ########################### VARS ###########################
    routeTableName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' $defFile)
    association=$(yq e '.Resources.attributes| to_entries | map(.value) | .[1]' $defFile)
    az=$(yq e '.Resources.attributes| to_entries | map(.value) | .[2]' $defFile)
    routeDest=$(yq e '.Resources.attributes| to_entries | map(.value) | .[3]' $defFile)
    igwDet=$(yq e '.Resources.attributes| to_entries | map(.value) | .[4]' $defFile)
    tagKey=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' $defFile))
    tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' $defFile))
    ########################### VARS ###########################
    echo "routeTableName="$routeTableName > PROPERTIES/$propFile

    checkIfSubnetExist $association $preReq2
        case `echo $?` in
        0)
        echo "subnet found"
        #create Route Table
        createRt $vpcId $routeTableName
        ;;
        1)
        echo "subnet not found"
        esac    
    # generate Route table Id
    newRoutTableId=$(aws ec2 describe-route-tables --filters "Name=tag:Name,Values=$routeTableName" --query "RouteTables[].RouteTableId" --output text) 

    for rtId in $newRoutTableId
    do
        # Adding tags
        echo "routeTableId="$rtId >> PROPERTIES/$propFile
        for ((i=0;i<${#tagKey[@]};i++))
        do
            addTags ${tagKey[i]} ${tagValue[i]} $rtId           
        done
    #associate subnets
    aws ec2 associate-route-table --route-table-id $rtId --subnet-id $subnetId
    #define routes
    checkIfIgwExist $igwDet $preReq3
        case `echo $?` in
        0)
        echo "IGW found"
        aws ec2 create-route --route-table-id $rtId --destination-cidr-block $routeDest --gateway-id $IgwId
        ;;
        1)
        echo "IGW not found"
        esac  
        
          
    done

}

function checkIfIgwExist(){
    igwName=$1
    preReq3=$2
    grep -Fxq "igwName=$igwName" PROPERTIES/$preReq3 
    # 0)

}

function checkIfSubnetExist(){
    association=$1
    preReq2=$2
    grep -Fxq "subnetName=$association" PROPERTIES/$preReq2 
    # 0)

}

function createRt() {
    vpcId=$1
    rtName=$2
    aws ec2 create-route-table --vpc-id $vpcId --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$rtName}]"
}

function addTags() {
    tagKey=$1
    tagValue=$2
    RTID=$3
        echo "key: " $tagKey
        echo "value: " $tagValue
      aws ec2 create-tags --resources $RTID --tags Key=$tagKey,Value=$tagValue
}