#!/bin/bash

# Set your project ID and bucket name
PROJECT_ID="devfestprep1"
BUCKET_NAME="devfest2024prep"
SA_NAME="github-actions-${BUCKET_NAME}"
SA_DISPLAY_NAME="GitHub Actions for ${BUCKET_NAME}"

# Set the project
gcloud config set project $PROJECT_ID

# Create a new bucket
gsutil mb -p $PROJECT_ID -c standard -l us-east1 -b on gs://$BUCKET_NAME

# Enable website configuration on the bucket
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

# Make the bucket publicly readable
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Upload index.html and 404.html files
gsutil cp index.html gs://$BUCKET_NAME
gsutil cp 404.html gs://$BUCKET_NAME

# Set the correct Content-Type for HTML files
gsutil setmeta -h "Content-Type:text/html" gs://$BUCKET_NAME/*.html

# Create a new service account
gcloud iam service-accounts create $SA_NAME \
    --display-name="$SA_DISPLAY_NAME"

# Get the full service account email
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SA_DISPLAY_NAME" \
    --format='value(email)')

# Assign roles to the service account for this specific bucket
gsutil iam ch serviceAccount:$SA_EMAIL:objectAdmin gs://$BUCKET_NAME

# Create and download a JSON key file
gcloud iam service-accounts keys create ./key.json \
    --iam-account="$SA_EMAIL"

# Output the content of the key file
echo "Here's your service account key. Use this for your GitHub Actions secret:"
cat ./key.json

# Clean up: remove the key file from your local machine
rm ./key.json

# Display the website URL
echo "Your website is now available at: https://storage.googleapis.com/$BUCKET_NAME/index.html"

echo "Remember to add the service account key to your GitHub repository secrets as GCP_SA_KEY"
echo "Also add your project ID ($PROJECT_ID) as GCP_PROJECT_ID and bucket name ($BUCKET_NAME) as GCP_BUCKET_NAME in your GitHub secrets"