# Build and Deploy Instructions

## Before you start
Create a `.env` file which looks like this:
```shell
GCP_REGION="europe-west2"
GCP_PROJECT_ID="gcp-project_id"
TERRAFORM_SERVICE_ACCOUNT=hello-terraform@gcp-project-id.iam.gserviceaccount.com
```
The value of the TERRAFORM_SERVICE_ACCOUNT variable should be the Terraform service account which is described in [./terraform/README.md](./terraform/README.md).

## Build and deploy
Log into the GCloud CLI using:
```shell
gcloud auth login
```

If you are on a corporate machine using ZScaler, copy your ZScaler cert into the current directory:
```shell
cp /usr/local/share/ca-certificates/zscaler.crt .     
```

Ensure that your account has `Service Account Token Creator` in GCP IAM so you can impersonate the Terraform service account.
Run the deploy script using:
```shell
./buildAndDeployDockerImage.sh
```

## Testing the function
Get the access token for your currently logged in user using the gcloud cli:
```shell
TOKEN=`gcloud auth print-identity-token`
```

Then you can use that token as a Bearer token in the Authorization header.  To use curl:
```shell
curl -X GET \
  'https://hello-7hjk8vgh.nw.gateway.dev/hello?name=World' \
  -H "Authorization: Bearer ${TOKEN}"
```
or wget:
```shell
wget --header="Authorization: Bearer ${TOKEN}" \
    'https://hello-7hjk8vgh.nw.gateway.dev/hello?name=World' \
     -O - | more
```