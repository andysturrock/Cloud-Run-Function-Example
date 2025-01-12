# Build and Deploy Instructions

## Before you start
Create a `.env` file which looks like this:
```shell
GCP_REGION="europe-west2"
GCP_PROJECT_ID="gcp-project-name"
TERRAFORM_SERVICE_ACCOUNT=hello-terraform-123@gcp-project-name.iam.gserviceaccount.com
```
The value of the TERRAFORM_SERVICE_ACCOUNT variable should be the Terraform service account which is described in [./terraform/README.md](./terraform/README.md).

## Build and deploy
Log into the GCloud CLI and set up your Application Default Credentials using:
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
Set the environment variable GCP_PROJECT_ID in your current shell:
```shell
GCP_PROJECT_ID="gcp-project-name"
```
 
Find the URL of the gateway using this command:
```shell
URL=$(gcloud api-gateway gateways list \
  --project=${GCP_PROJECT_ID} \
  --format="table(defaultHostname)" | grep hello)
```

Check that the URL variable is now set to something like `hello-abc123.nw.gateway.dev`:
```shell
echo $URL
```
If it is not, then use the GCP Console to find the URL of the gateway and set the environment variable manually.

Get the access token for your currently logged in user using the gcloud cli:
```shell
TOKEN=`gcloud auth print-identity-token`
```

Then you can use that token as a Bearer token in the Authorization header.  To use curl:
```shell
curl -X GET \
  "https://${URL}/hello?name=World" \
  -H "Authorization: Bearer ${TOKEN}"
```
or wget:
```shell
wget --header="Authorization: Bearer ${TOKEN}" \
    'https://hello-abc123.nw.gateway.dev/hello?name=World' \
     -O - | more
```