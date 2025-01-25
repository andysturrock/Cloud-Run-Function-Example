#!/bin/bash

set -eo pipefail

echo "Sourcing environment from ../.env..."
. ../.env

# Create a suffix for all the accounts and roles below.
# They need to be unique and GCP soft deletes roles.
# This allows re-running the script multiple times.
suffix=$(date +%s)

echo "Creating service account..."
gcloud iam service-accounts create "hello-terraform-${suffix}" \
  --display-name="Hello Terraform-${suffix}" \
   --project=${GCP_PROJECT_ID}

PERMISSIONS=$(
cat << 'EOF'
apigateway.apiconfigs.create
apigateway.apiconfigs.delete
apigateway.apiconfigs.get
apigateway.apis.create
apigateway.apis.delete
apigateway.apis.get
apigateway.gateways.create
apigateway.gateways.delete
apigateway.gateways.get
apigateway.gateways.list
apigateway.operations.get
artifactregistry.repositories.create
artifactregistry.repositories.delete
artifactregistry.repositories.downloadArtifacts
artifactregistry.repositories.get
artifactregistry.repositories.getIamPolicy
artifactregistry.repositories.setIamPolicy
artifactregistry.repositories.update
artifactregistry.repositories.uploadArtifacts
iam.serviceAccounts.actAs
iam.serviceAccounts.create
iam.serviceAccounts.delete
iam.serviceAccounts.get
iam.serviceAccounts.getAccessToken
resourcemanager.projects.get
run.operations.get
run.services.create
run.services.delete
run.services.get
run.services.getIamPolicy
run.services.list
run.services.setIamPolicy
run.services.update
serviceusage.services.list
storage.objects.create
storage.objects.delete
storage.objects.get
storage.objects.list
EOF
)

# Turn newlines into commas
PERMISSIONS=$(echo "$PERMISSIONS" | tr '\n' ',')
# Remove trailing comma
PERMISSIONS=${PERMISSIONS%,}

echo "Creating role..."
# Note the rolename can't contain a - character (allowed pattern is "[a-zA-Z0-9_\.]{3,64}")
gcloud iam roles create "HelloTerraform${suffix}" \
  --project=${GCP_PROJECT_ID} \
  --title="Hello Terraform-${suffix}" \
  --description="Permissions for Hello Terraform-${suffix}" \
  --permissions=${PERMISSIONS} \
  --stage=GA

echo "Assigning role to service account..."
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} --member="serviceAccount:hello-terraform-${suffix}@${GCP_PROJECT_ID}.iam.gserviceaccount.com" --role="projects/${GCP_PROJECT_ID}/roles/HelloTerraform${suffix}"
echo "Done."

echo "Service account hello-terraform-${suffix}@${GCP_PROJECT_ID}.iam.gserviceaccount.com is ready for use."

