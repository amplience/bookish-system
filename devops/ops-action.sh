#!/bin/env bash

clear

#set -e
#set -x

# allowing using aliases in bash script
shopt -s expand_aliases

v_path_core="/mnt/c/hub/CloudSTI/csti-python/prototypes/assesment/bookish-system/devops/"
v_aws_amplience_username="amplience-user"
v_aws_amplience_policy_name="amplience-user-policy"
v_aws_amplience_policy_json_filename="$v_path_core/aws-iam-policies/aws-amplience-user-policy.json"
v_aws_account_id="224674423298"
v_aws_amplience_policy_arn="arn:aws:iam::$v_aws_account_id:policy/$v_aws_amplience_policy_name"

# ALIAS for om-root to create a new account with limited permissions
alias aws-pr='aws --profile om-root --region eu-west-2'

# ALIAS for amplience-user
alias aws-au='aws --profile amplience-user --region eu-west-2'


#v_check_is_exists_and_added_user_policy=$(aws-pr iam get-user --user-name $v_aws_amplience_username | grep -i $v_aws_amplience_policy_arn)
v_check_is_exists_and_added_user_policy=$(aws-pr iam list-attached-user-policies --user-name $v_aws_amplience_username | grep -i $v_aws_amplience_policy_arn)

# CloudFormation deploy

v_cloudformation_network_stack_name="AmplienceNetworkResources"
v_cloudformation_network_stack_filename="cfn-networking.yaml"

# first create of cloudformation stack
aws-au cloudformation create-stack --stack-name $v_cloudformation_network_stack_name --template-body file://cloudformation/$v_cloudformation_network_stack_filename
# command for updates of cloudformation stack
#aws-au cloudformation update-stack --stack-name $v_cloudformation_network_stack_name --template-body file://cloudformation/$v_cloudformation_network_stack_filename

v_cloudformation_iam_stack_name="AmplienceIAMResources"
v_cloudformation_iam_stack_filename="cfn-iam.yaml"

# first create of cloudformation stack
aws-au cloudformation create-stack --stack-name $v_cloudformation_iam_stack_name --template-body file://cloudformation/$v_cloudformation_iam_stack_filename --capabilities CAPABILITY_NAMED_IAM
# command for updates of cloudformation stack
#aws-au cloudformation update-stack --stack-name $v_cloudformation_iam_stack_name --template-body file://cloudformation/$v_cloudformation_iam_stack_filename --capabilities CAPABILITY_NAMED_IAM

v_cloudformation_ecr_stack_name="AmplienceECRResource"
v_cloudformation_ecr_stack_filename="cfn-ecr.yaml"

# first create of cloudformation stack
aws-au cloudformation create-stack --stack-name $v_cloudformation_ecr_stack_name --template-body file://cloudformation/$v_cloudformation_ecr_stack_filename
# command for updates of cloudformation stack
#aws-au cloudformation update-stack --stack-name $v_cloudformation_ecr_stack_name --template-body file://cloudformation/$v_cloudformation_ecr_stack_filename

v_cloudformation_ecs_stack_name="AmplienceECSResources"
v_cloudformation_ecs_stack_filename="cfn-ecs.yaml"

# first create of cloudformation stack
aws-au cloudformation create-stack --stack-name $v_cloudformation_ecs_stack_name --template-body file://cloudformation/$v_cloudformation_ecs_stack_filename
# command for updates of cloudformation stack
#aws-au cloudformation update-stack --stack-name $v_cloudformation_ecs_stack_name --template-body file://cloudformation/$v_cloudformation_ecs_stack_filename

v_cloudformation_api_stack_name="AmplienceAPIResources"
v_cloudformation_api_stack_filename="cfn-api.yaml"

# first create of cloudformation stack
aws-au cloudformation create-stack --stack-name $v_cloudformation_api_stack_name --template-body file://cloudformation/$v_cloudformation_api_stack_filename
# command for updates of cloudformation stack
#aws-au cloudformation update-stack --stack-name $v_cloudformation_api_stack_name --template-body file://cloudformation/$v_cloudformation_api_stack_filename
