Assumptions:
1. AWS ECS is the most accessible form of running containers and maintaining them.
2. Originally, I wanted to give minimal permissions by examining step by step what I need to add, but AWS forced me to use the Administrator role for a dedicated user (sometimes it is not clear which service should be added to push the process forward).
But roles for ECS are minimalist access granted (not administrator).
3. A dedicated user has been created to perform operations from the terminal.
4. I used Cloudformation as an Infrastrucuture as Code tool.
5. Additionally, I supported the process using AWS CLI and sometimes AWS Web Console.

VPC: CIDR 10.0.0.0/16
Subnet Private: 10.0.21.0/24
Subnet Public: 10.0.11.0/24
Subnet Public: 10.0.12.0/24

Process phases:
1. Preparing a user with permissions.
2. Preparation of resources for the network.
3. Preparing the AWS ECS cluster.
4. Preparation of resources for running applications.

Finally, the URL where the application is available:
http://ecs-services-1505775773.eu-west-2.elb.amazonaws.com/

Additionally, can be used AWS Route 53 to sign a pretty domain name.
Has been used load balancer with SSL certificate.

--------------------------------------------------------------------------------------------------------------------------------
1. Preparing a user with permissions.
--------------------------------------------------------------------------------------------------------------------------------

Log in to your AWS administrator account.
Get the access/secret key of this account.
Configure the profile "om-root" in the terminal.

COMMAND:
aws configure --profile om-root

OUTPUT:
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]: eu-west-2
Default output format [None]: json

Use admin user credentials and create a new account with right permissions.

# to set variables and aliases for AWS CLI for two aws profiles
COMMANDS to run on the terminal:

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


COMMAND:
aws-pr iam create-user --user-name $v_aws_amplience_username

OUTPUT:
{
    "User": {
        "Path": "/",
        "UserName": "amplience-user",
        "UserId": "AIDATIT5DUIBIXTBHSW2A",
        "Arn": "arn:aws:iam::224674423298:user/amplience-user",
    }
}

create filename with content: aws-iam-policies/aws-amplience-user-policy.json

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:StartInstances",
        "ec2:StopInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*"
    }
  ]
}

Alternative version of json file: (but later I have added Administrator role due not clear what access should be granted later)

{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sts:DecodeAuthorizationMessage"
      ],
      "Resource": "*"
    }
  ]
}


COMMAND:
aws-pr iam attach-user-policy --user-name 'amplience-user' --policy-arn 'arn:aws:iam::aws:policy/AdministratorAccess'
echo "v_aws_amplience_policy_json_filename: $v_aws_amplience_policy_json_filename"
aws-pr iam create-policy --policy-name $v_aws_amplience_policy_name --policy-document file://$v_aws_amplience_policy_json_filename

OUTPUT:
{
    "Policy": {
        "PolicyName": "amplience-user-policy",
        "PolicyId": "ANPATIT5DUIBOWD4BNKSB",
        "Arn": "arn:aws:iam::224674423298:policy/amplience-user-policy",
        "Path": "/",
        "DefaultVersionId": "v1",
        "AttachmentCount": 0,
        "PermissionsBoundaryUsageCount": 0,
        "IsAttachable": true,
    }
}

COMMANDS:
aws-pr iam attach-user-policy --policy-arn $v_aws_amplience_policy_arn --user-name $v_aws_amplience_username

OUTPUT:
no output

aws-pr iam get-user --user-name $v_aws_amplience_username

OUTPUT:

{
    "User": {
        "Path": "/",
        "UserName": "amplience-user",
        "UserId": "AIDATIT5DUIBIXTBHSW2A",
        "Arn": "arn:aws:iam::224674423298:user/amplience-user",
    }
}

STEP in browser - Go to IAM service on AWS Web Console and get credentials to set in profile in the terminal
https://us-east-1.console.aws.amazon.com/iamv2/home?region=us-east-1#/users/details/amplience-user?section=permissions

STEP in terminal

COMMAND:
aws configure --profile amplience-user

AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]: eu-west-2
Default output format [None]: json

COMMAND to test limited access to AWS resources:
aws-au s3 ls
An error occurred (AccessDenied) when calling the ListBuckets operation: Access Denied




--------------------------------------------------------------------------------------------------------------------------------
2. Preparation of resources for the network.
3. Preparing the AWS ECS cluster.
4. Preparation of resources for running applications.
--------------------------------------------------------------------------------------------------------------------------------

# Bash Script with auto create/update resources required for containerized application. [ ops-action.sh ]

cd /mnt/c/hub/CloudSTI/csti-python/prototypes/assesment/bookish-system/devops

# other commands are included in file below (file is avaibale in the repository)
./ops-action.sh # file located in repository


# Praparation of docker image and push to AWS ECR

cd /mnt/c/hub/CloudSTI/csti-python/prototypes/assesment/bookish-system/devops

aws-au ecr get-login-password --region eu-west-2 | docker login --username AWS --password-stdin 224674423298.dkr.ecr.eu-west-2.amazonaws.com

OUTPUT:
Login Succeeded
Logging in with your password grants your terminal complete access to your account.
For better security, log in with a limited-privilege personal access token. Learn more at https://docs.docker.com/go/access-tokens/

docker build -t amplienceecr .

OUTPUT:
[+] Building 19.8s (8/8) FINISHED
 => [internal] load .dockerignore                                                                                                                                                        0.1s
 => => transferring context: 2B                                                                                                                                                          0.0s
 => [internal] load build definition from Dockerfile                                                                                                                                     0.1s
 => => transferring dockerfile: 118B                                                                                                                                                     0.0s
 => [internal] load metadata for docker.io/library/node:19-alpine                                                                                                                        1.9s
 => [auth] library/node:pull token for registry-1.docker.io                                                                                                                              0.0s
 => [internal] load build context                                                                                                                                                        0.1s
 => => transferring context: 397B                                                                                                                                                        0.0s
 => [1/2] FROM docker.io/library/node:19-alpine@sha256:013a0703e961e02b8be69a548f2356ae5b17bc5b8570f1cdd4b97650200b6860                                                                 17.5s
 => => resolve docker.io/library/node:19-alpine@sha256:013a0703e961e02b8be69a548f2356ae5b17bc5b8570f1cdd4b97650200b6860                                                                  0.0s
 => => sha256:682168483616c38739cbff47152f7fe6a49eb19f537f8b2a6b9a4de537dfe8e3 2.35MB / 2.35MB                                                                                           5.3s
 => => sha256:013a0703e961e02b8be69a548f2356ae5b17bc5b8570f1cdd4b97650200b6860 1.43kB / 1.43kB                                                                                           0.0s
 => => sha256:0e9961345f0ef2ea3e132990e814a26cb9fa8f89e50abb68751c6bc45ca014c4 1.16kB / 1.16kB                                                                                           0.0s
 => => sha256:adb3ed8bc61ee6fb46e5ece58f9821faf5fe5be4e1ef34e678b322639f17852a 6.48kB / 6.48kB                                                                                           0.0s
 => => sha256:f56be85fc22e46face30e2c3de3f7fe7c15f8fd7c4e5add29d7f64b87abdaa09 3.37MB / 3.37MB                                                                                           2.1s
 => => sha256:62f73f92a48b45933d543f6852c1ad59f15d5490ea0c41f81ed72401029d1133 48.15MB / 48.15MB                                                                                        15.5s
 => => extracting sha256:f56be85fc22e46face30e2c3de3f7fe7c15f8fd7c4e5add29d7f64b87abdaa09                                                                                                0.3s
 => => sha256:f8910f76fdcf8bd7827fe470eefe39ad8b979fbba64dcf553ae13adf812d3203 448B / 448B                                                                                               2.4s
 => => extracting sha256:62f73f92a48b45933d543f6852c1ad59f15d5490ea0c41f81ed72401029d1133                                                                                                1.6s
 => => extracting sha256:682168483616c38739cbff47152f7fe6a49eb19f537f8b2a6b9a4de537dfe8e3                                                                                                0.1s
 => => extracting sha256:f8910f76fdcf8bd7827fe470eefe39ad8b979fbba64dcf553ae13adf812d3203                                                                                                0.0s
 => [2/2] COPY src/index.js /index.js                                                                                                                                                    0.3s
 => exporting to image                                                                                                                                                                   0.0s
 => => exporting layers                                                                                                                                                                  0.0s
 => => writing image sha256:d559661c5c583b62f00a91e77eb017c0120307403755fd3dcceb1d7ba53d432b                                                                                             0.0s
 => => naming to docker.io/library/amplienceecr

docker tag ecramplience:latest 224674423298.dkr.ecr.eu-west-2.amazonaws.com/ecramplience:latest

docker push 224674423298.dkr.ecr.eu-west-2.amazonaws.com/ecramplience:latest
