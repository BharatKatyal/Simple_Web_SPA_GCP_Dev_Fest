#!/bin/bash

# Set your project ID and bucket name
PROJECT_ID="devfestprep1"
BUCKET_NAME="devfest2024prep"
SA_NAME="github-actions-${BUCKET_NAME}"

# Set the project
gcloud config set project $PROJECT_ID

# Delete the bucket and its contents
gsutil rm -r gs://$BUCKET_NAME

# Get the full service account email
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:GitHub Actions for ${BUCKET_NAME}" \
    --format='value(email)')

# Delete the service account
gcloud iam service-accounts delete $SA_EMAIL --quiet

echo "Cleanup completed. The following resources have been removed:"
echo "- Bucket: $BUCKET_NAME"
echo "- Service Account: $SA_EMAIL"
echo "Please note: If you've used this service account in GitHub Actions, remember to remove the corresponding secrets from your GitHub repository."