# amplience-devops-interview-test

This is the Amplience practical test for DevOps applicants.

In this repository you have a simple node app. It runs on port 8000 and emits the string "Hello world".

You can test the app by running `npm start` or using the included `Dockerfile`.

## Pre-requisites

You will need free AWS account, which you can [sign up for here](https://aws.amazon.com/free/) or use one you already have access to.

## Instructions

Your task is to build a stack using an Infrastructure-as-Code tool that will 
1. Deploy this app to an AWS environment
2. Provide the endpoint to access the app, as part of the stack or modules outputs.

You may use any tool that you wish, however you should bear in mind that our team are most familiar with
Terraform, CloudFormation and CDK. Please provide us with
1. The code to deploy the infrastructure
2. Instructions on how to deploy it.

The code will be run from a shell that has AWS credentials set up to an empty account. You may assume a default
VPC is in place should you wish to use one.

Other than that, you have a free choice in the service or tool you use to host the app. You can pull this repository down as a package using [this link](), or any other suitable means to get it into your service.

## Submitting code for review

1. Please create a fork of this repo using the `+ Create a new fork` option in the top right of this repo. 
2. Clone your fork to your machine
3. Create a new branch called `feature/test-submission`
4. Add your Infrastructure-as-Code, along with any instructions to deploy it. 
5. Once you are ready to submit, please create a `Pull Request` back into the original repository.

