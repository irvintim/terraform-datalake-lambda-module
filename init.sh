#!/usr/bin/env bash

TF_STATE="terraform-lambda-phonedata-getreport-ses/terraform.tfstate"
TF_LOCK="terraform-lambda-phonedata-getreport-sesTerraformStateLock"
GIT_TAG="terraform-lambda-phonedata-getreport-ses"

echo "Removing .terraform, terraform.tfplan terraform.tfstate* files"
rm -Rf .terraform
rm -Rf terraform.tfplan
rm -Rf terraform.tfstate*

echo "terraform init -backend-config=key=$TF_STATE -backend-config=dynamodb_table=$TF_LOCK -get=true -upgrade=true"
terraform init -backend-config=key=$TF_STATE -backend-config=dynamodb_table=$TF_LOCK -get=true -upgrade=true

read -p "Should the tag be moved? (NO when destroying) [y/n] " answer
case ${answer:0:1} in
    y|Y )
    	echo "Creating tag $GIT_TAG" && git tag -fa $GIT_TAG -m 'New environment' && echo "Pushing tag $GIT_TAG to origin" && git push -f origin $GIT_TAG && exit;;
    * )
		echo "Tag NOT moved" && exit;;
esac