# Terraform instructions

## Before starting

Create a bucket in your GCP project to hold Terraform state.  Call it something like `gcp-project-name-tfstate` so it is globally unique.

Add the bucket name to the `hello.tfbackend` file which should then look like:
```
bucket = "prj-i-swift-shark-d56e-tfstate"
prefix = "terraform/hello/state"
```

Then init Terraform by running:
```shell
terraform init
```

Create service account in your GCP project for running Terraform.  Call it something like `hello-terraform` so its email address is something like `hello-terraform@gcp-project-name.iam.gserviceaccount.com`.

Add the service account name to the `terraform.tfvars` file which should then look like:
```terraform
terraform_service_account = "hello-terraform@gcp-project-name.iam.gserviceaccount.com"
gcp_project_name          = "gcp-project-name"
gcp_region                = "europe-west2"
cloudrun_container_id     = "hello:latest"
api_display_name          = "hello"
api_gateway_id            = "hello"
```
Change the GCP region as required.

Create a role for the Terraform service account.  Call it something like `Hello Terraform`.  It should have the following permissions:
```
```

Ensure that your account has `Service Account Token Creator` in GCP IAM so you can impersonate the Terraform service account.
Login and set service account impersonation on your GCloud local credentials by running:
```shell
gcloud auth login
gcloud config set auth/impersonate_service_account hello-terraform@gcp-project-name.iam.gserviceaccount.com
```

Run the Terraform to create everything:
```shell
terraform apply -auto-approve
```

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

Creating the API Gateway parts can take several minutes - eg:

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

