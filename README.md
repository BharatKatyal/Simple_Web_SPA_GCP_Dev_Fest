# Simple_Web_SPA_GCP_Dev_Fest
DevFest 2024 Workshop

Backup Workshop: https://codelabs.developers.google.com/codelabs/how-to-cloud-run-gemini-function-calling#0







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

