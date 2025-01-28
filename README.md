# Build and Deploy Instructions

## Before you start

First follow the instructions in [./terraform/README.md](./terraform/README.md).

Create a `.env` file which looks like this:
```shell
GCP_REGION="europe-west2"
GCP_PROJECT_ID="gcp-project-name"
TERRAFORM_SERVICE_ACCOUNT=hello-terraform-123@gcp-project-name.iam.gserviceaccount.com
```

The value of the TERRAFORM_SERVICE_ACCOUNT variable should be the Terraform service account which you created in the terraform instructions. 

## Build and deploy
If you are on a corporate machine using ZScaler, copy your ZScaler cert into the current directory:
```shell
cp /usr/local/share/ca-certificates/zscaler.crt .     
```

Run the deploy script using:
```shell
./buildAndDeployDockerImage.sh
```

## Testing the function
Pull in the environment variable from `.env` which will set GCP_PROJECT_ID in your current shell:
```shell
. ./.env
```

Log into the GCloud CLI using:
```shell
gcloud auth login
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
    "https://${URL}/hello?name=World" \
     -O - | cat
```