#!/bin/bash
#set -x

cidr=$(yq e '.Resources.attributes| to_entries | map(.value) | .[1]' vpc.yml)
vpcName=$(yq e '.Resources.attributes| to_entries | map(.value) | .[0]' vpc.yml)
az=$(yq e '.Resources.attributes| to_entries | map(.value) | .[2]' vpc.yml)
tagy=($(yq e '.Resources.tags| to_entries | map(.key) | .[]' vpc.yml))
tagValue=($(yq e '.Resources.tags| to_entries | map(.value) | .[]' vpc.yml))

# function createVpc() {
# aws ec2 create-vpc--cidr-block $cidr 
# }

# function tagsForVpc(){
#     aws ec2 create-tags --resources i-0e9b27e006270f54f --tags Key=Name,Value=MyInstance
# }

# VPCID=$(aws ec2 describe-vpcs --filters "Name=cidr,Values=172.31.0.0/16" --query "Vpcs[].VpcId" --output text)
# for vpcId in $VPCID
# do
#     echo "$vpcId"
#     aws ec2 create-tags --resources i-0e9b27e006270f54f --tags Key=Name,Value=MyInstance
# done


for ((i=0;i<${#tagy[@]};i++))
do
    #for j in ${tagValue[@]}
    #do
        echo $i
        echo "key: " ${tagy[i]}
        echo "value: " ${tagValue[i]}
        echo "aws ec2 create-tags --resources i-0e9b27e006270f54f --tags Key=${tagy[i]},Value=${tagValue[i]}"
    #done
done