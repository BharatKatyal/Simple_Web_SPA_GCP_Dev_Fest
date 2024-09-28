# Set your project ID
PROJECT_ID="your-project-id"
BUCKET_NAME="your-bucket-name"

# Set the project
gcloud config set project $PROJECT_ID

# Create a new bucket
gsutil mb -p $PROJECT_ID -c standard -l us-central1 -b on gs://$BUCKET_NAME

# Enable website configuration on the bucket
gsutil web set -m index.html -e 404.html gs://$BUCKET_NAME

# Make the bucket publicly readable
gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME

# Upload index.html and 404.html files
gsutil cp index.html gs://$BUCKET_NAME
gsutil cp 404.html gs://$BUCKET_NAME

# Set the correct Content-Type for HTML files
gsutil setmeta -h "Content-Type:text/html" gs://$BUCKET_NAME/*.html

# Display the website URL
echo "Your website is now available at: https://storage.googleapis.com/$BUCKET_NAME/index.html"