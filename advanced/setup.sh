#!/bin/bash

# Set your project ID and bucket name
PROJECT_ID="devfestprep1"
BUCKET_NAME="myprepv2-devfes"
SA_NAME="github-actions-${BUCKET_NAME}"
LB_NAME="${BUCKET_NAME}-lb"
CUSTOM_ROLE_NAME="githubActionsLoadBalancerRole"

# Set the project
gcloud config set project $PROJECT_ID

# Delete the load balancer components
echo "Deleting load balancer components..."
gcloud compute forwarding-rules delete $LB_NAME-http --global --quiet
gcloud compute target-http-proxies delete $LB_NAME-proxy --quiet
gcloud compute url-maps delete $LB_NAME --quiet
gcloud compute backend-buckets delete $LB_NAME --quiet

# Delete the bucket
echo "Deleting bucket..."
gsutil rm -r gs://$BUCKET_NAME

# Get the service account email
SA_EMAIL=$(gcloud iam service-accounts list --filter="displayName:GitHub Actions for ${BUCKET_NAME}" --format='value(email)')

# Remove the custom role from the service account
echo "Removing custom role from service account..."
gcloud projects remove-iam-policy-binding $PROJECT_ID --member="serviceAccount:$SA_EMAIL" --role="projects/$PROJECT_ID/roles/$CUSTOM_ROLE_NAME"

# Delete the custom role
echo "Deleting custom role..."
gcloud iam roles delete $CUSTOM_ROLE_NAME --project=$PROJECT_ID --quiet

# Undelete and fully delete the custom role if it's in a deleted state
echo "Ensuring custom role is fully deleted..."
gcloud iam roles undelete $CUSTOM_ROLE_NAME --project=$PROJECT_ID --quiet
gcloud iam roles delete $CUSTOM_ROLE_NAME --project=$PROJECT_ID --quiet

# Delete the service account
echo "Deleting service account..."
gcloud iam service-accounts delete $SA_EMAIL --quiet

echo "Cleanup completed. The following resources have been deleted:"
echo "- Load Balancer: $LB_NAME"
echo "- Bucket: $BUCKET_NAME"
echo "- Service Account: $SA_EMAIL"
echo "- Custom Role: $CUSTOM_ROLE_NAME"

echo "Please remember to remove the corresponding secrets from your GitHub repository."