# Terraform instructions

## Before starting

In all the instructions below, substitute `gcp-project-name` for the name of your project.

### Create Terraform service account
Create a `.env` file in the top level directory which should look like this:
```shell
GCP_REGION="europe-west2"
GCP_PROJECT_ID="gcp-project-name"
```
Create service account in your GCP project for running Terraform using the [createTerraformServiceAccount.sh](./createTerraformServiceAccount.sh) script.  The script will have  so its email address is something like `hello-terraform@gcp-project-name.iam.gserviceaccount.com`.

The script will create the service account and its last line of output should look something like:
```
Service account hello-terraform-1736692837@gcp-project-name.iam.gserviceaccount.com is ready for use.
```

Note that each time the script is run a new service account and role will be created.  The number like `1736692837` will change (it's the Unix timestamp from when the script runs).  This is because GCP soft-deletes roles so their names must be unique when you create a new one.

Edit the `.env` file to add the service account:
```shell
GCP_REGION="europe-west2"
GCP_PROJECT_ID="gcp-project-name"
TERRAFORM_SERVICE_ACCOUNT="hello-terraform-1736692837@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
```

### Initialise Terraform
Create a bucket in your GCP project to hold Terraform state.  Call it something like `gcp-project-name-tfstate` so it is globally unique.

Delete any previous Terraform config:
```shell
rm -rf .terraform .terraform.lock.hcl
```

Pull in the values from the .env file into your current shell:
```shell
. ../.env
```

Login and set your GCloud local credentials by running:
```shell
gcloud config unset auth/impersonate_service_account
gcloud auth application-default login
gcloud config set project ${GCP_PROJECT_ID}
```

Then init Terraform by running:
```shell
terraform init
```
Type in the name of your bucket when asked.

Ensure that your account has `Service Account Token Creator` in GCP IAM so you can impersonate the Terraform service account:
```shell
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
  --member="user:$(gcloud config get-value account)" \
  --role="roles/iam.serviceAccountTokenCreator"
```

Set your login to impersonate the Terraform service account:
```shell
gcloud config set auth/impersonate_service_account ${TERRAFORM_SERVICE_ACCOUNT}
```

### Run Terraform

Create a `terraform.tfvars` file with the following contents (replacing the project name and service account):
```terraform
terraform_service_account = "hello-terraform-1736692837@gcp-project-name.iam.gserviceaccount.com"
gcp_project_name          = "gcp-project-name"
gcp_region                = "europe-west2"
cloudrun_container_id     = "hello:latest"
api_display_name          = "hello"
api_gateway_id            = "hello"
```
Change the GCP region as required.

Run the Terraform to create everything:
```shell
terraform apply -auto-approve
```

You may get errors about APIs not being enabled, something like:
```shell
 Error: Error creating Api: googleapi: Error 403: API Gateway API has not been used in project gcp-project-name before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/apigateway.googleapis.com/overview?project=gcp-project-name then retry. If you enabled this API recently, wait a few minutes for the action to propagate to our systems and retry.
```
As the message suggests, wait a minute or two and then rerun the `terraform apply` command.

The first time you run the Terraform apply command it will fail as there will be no Docker image in the Artifact repository.  The error will look something like:
```
╷
│ Error: Error waiting to create Service: Error waiting for Creating Service: Error code 13, message: Revision 'hello-00001-b5g' is not ready and cannot serve traffic. Image 'europe-west2-docker.pkg.dev/my-gcp-project/hello/hello:latest' not found.
│
│   with google_cloud_run_v2_service.hello,
│   on cloud_run_service.tf line 1, in resource "google_cloud_run_v2_service" "hello":
│    1: resource "google_cloud_run_v2_service" "hello" {
│
╵
```

To fix this follow the instructions in the [top level README.md](../README.md) and use the [deploy script](../buildAndDeployDockerImage.sh) to build and deploy an image.  Then run `terraform apply` again.

Note that creating the API Gateway parts can take several minutes - eg:

```
google_api_gateway_api.hello: Still creating... [1m40s elapsed]
google_api_gateway_api.hello: Creation complete after 1m49s [id=projects/my-gcp-project/locations/global/apis/hello]
...
google_api_gateway_api_config.hello: Still creating... [2m10s elapsed]
google_api_gateway_api_config.hello: Still creating... [2m20s elapsed]
google_api_gateway_api_config.hello: Creation complete after 2m22s [id=projects/my-gcp-project/locations/global/apis/hello/configs/terraform-20250110184133286900000001]
...
google_api_gateway_gateway.hello: Still creating... [2m0s elapsed]
google_api_gateway_gateway.hello: Still creating... [2m10s elapsed]
google_api_gateway_gateway.hello: Creation complete after 2m13s [id=projects/my-gcp-project/locations/europe-west2/gateways/hello]
```

### Terraform errors
You might get an error saying the `google_cloud_run_v2_service.hello` service already exists.  If this is the case run this command:
```shell
gcloud run services delete hello --project=${GCP_PROJECT_ID} --region=${GCP_REGION}
```
Then re-run the `terraform apply -auto-approve` command again.

### Deploy new versions of the service
If you change the code for the service you can redeploy your new version by re-running the the [deploy script](../buildAndDeployDockerImage.sh).