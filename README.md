# Simple_Web_SPA_GCP_Dev_Fest
DevFest 2024 Workshop

Backup Workshop: https://codelabs.developers.google.com/codelabs/how-to-cloud-run-gemini-function-calling#0





Step1:  Deploy the Infrascture 
```
#!/bin/bash

# Set your project ID and bucket name
PROJECT_ID="devfestprep1"
BUCKET_NAME="devfest2024prep"
SA_NAME="github-actions-${BUCKET_NAME}"
SA_DISPLAY_NAME="GitHub Actions for ${BUCKET_NAME}"

# Set the project
gcloud config set project $PROJECT_ID

# Create a new bucket
echo "Creating bucket: $BUCKET_NAME"
gsutil mb -p $PROJECT_ID -c standard -l us-east1 -b on gs://$BUCKET_NAME

# Enable website configuration on the bucket
echo "Configuring bucket for website hosting"
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

# Make the bucket publicly readable
echo "Making bucket publicly readable"
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Set the correct Content-Type for HTML files
echo "Setting Content-Type for HTML files"
gsutil setmeta -h "Content-Type:text/html" gs://$BUCKET_NAME/*.html

# Create a new service account
echo "Creating service account: $SA_NAME"
gcloud iam service-accounts create $SA_NAME \
    --display-name="$SA_DISPLAY_NAME"

# Get the full service account email
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SA_DISPLAY_NAME" \
    --format='value(email)')

# Assign roles to the service account for this specific bucket
echo "Assigning roles to service account"
gsutil iam ch serviceAccount:$SA_EMAIL:objectAdmin gs://$BUCKET_NAME

# Assign additional roles for Cloud Functions and Cloud Build
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/cloudfunctions.developer"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/cloudbuild.builds.editor"

# Enable necessary APIs
echo "Enabling necessary APIs"
gcloud services enable cloudfunctions.googleapis.com
gcloud services enable cloudbuild.googleapis.com

# Create and download a JSON key file
echo "Creating service account key"
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
echo "Also add the following to your GitHub secrets:"
echo "- GCP_PROJECT_ID: $PROJECT_ID"
echo "- GCP_BUCKET_NAME: $BUCKET_NAME"
echo "- GCP_SA_EMAIL: $SA_EMAIL"
```

Step 2 : Setup Github Action, Place Website files under a /public directory as shown in the github actions
.github/workflows/deploy.yml

```
name: Deploy to GCP

# Controls when the action will run. Triggers the workflow on push or pull request
# events but only for the main branch
on:
  push:
    branches: [ main ]

env:
  BUCKET_NAME: ${{ secrets.BUCKET_NAME }} 
# A workflow run is made up of one or more jobs that can run sequentially or in parallel
jobs:
  # This workflow contains a single job called "deploy"
  deploy:
    # The type of runner that the job will run on
    runs-on: ubuntu-latest

    # Steps represent a sequence of tasks that will be executed as part of the job
    steps:
    # Checks-out your repository under $GITHUB_WORKSPACE, so your job can access it
    - uses: actions/checkout@v2

    # Setup gcloud CLI
    - uses: google-github-actions/setup-gcloud@v0
      with:
        service_account_email: ${{ secrets.GCP_SA_EMAIL }}
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: github-actions-gcs

    - name: Deploy via GCS
      run: |
        gsutil -m rm -rf gs://${{ env.BUCKET_NAME }}/* || echo "$?"
        gsutil -m cp -r public/* gs://${{ env.BUCKET_NAME }}/

```

Step 3: Add Repository secrets
Go to your repo -> Settings -> Repository secrets Add below from the output of Gcloud cli
BUCKET_NAME, GCP_SA_EMAIL, GCP_SA_KEY

Step 4: Push 




CLEAN UP SCRIPT
```
#!/bin/bash

# Set your project ID and bucket name
PROJECT_ID="devfestprep1"
BUCKET_NAME="devfest2024prep"
SA_NAME="github-actions-${BUCKET_NAME}"
SA_DISPLAY_NAME="GitHub Actions for ${BUCKET_NAME}"

# Set the project
gcloud config set project $PROJECT_ID

# Delete the bucket and its contents
echo "Deleting bucket: $BUCKET_NAME"
gsutil rm -r gs://$BUCKET_NAME

# Get the full service account email
SA_EMAIL=$(gcloud iam service-accounts list \
    --filter="displayName:$SA_DISPLAY_NAME" \
    --format='value(email)')

# Remove IAM policy binding for the bucket (if it still exists)
echo "Removing IAM policy binding for the bucket"
gsutil iam ch -d serviceAccount:$SA_EMAIL:objectAdmin gs://$BUCKET_NAME

# Delete the service account
echo "Deleting service account: $SA_EMAIL"
gcloud iam service-accounts delete $SA_EMAIL --quiet

echo "Cleanup completed. The following resources have been removed:"
echo "- Bucket: $BUCKET_NAME"
echo "- Service Account: $SA_EMAIL"

echo "Note: This script does not remove the project or disable any APIs. If you want to remove the project or disable APIs, you can do so manually in the Google Cloud Console."

echo "Remember to remove the corresponding secrets from your GitHub repository:"
echo "- GCP_SA_KEY"
echo "- GCP_PROJECT_ID"
echo "- GCP_BUCKET_NAME"
```






















Creating a Hello World Function VIA Gcloud CLI

# Create a directory for the function
mkdir -p my-function
cd my-function

# Create the function code
cat << EOF > index.js
exports.helloWorld = (req, res) => {
  res.status(200).send('Hello, World!');
};
EOF

# Create the package.json file
cat << EOF > package.json
{
  "name": "hello-world-function",
  "version": "1.0.0",
  "description": "A simple Hello World function",
  "main": "index.js",
  "engines": {
    "node": "18"
  }
}
EOF

# Deploy the Cloud Function
gcloud functions deploy hello-world \
  --runtime nodejs18 \
  --trigger-http \
  --allow-unauthenticated \
  --region us-central1 \
  --source . \
  --entry-point helloWorld











export PROJECT_ID="your-project-id"
export BUCKET_NAME="your-bucket-name"

