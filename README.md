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

There is also a [Python script](./test.py) provided which will call the service multiple times in parallel and time each call.  The output should look something like this:
```
python test.py
1. Hello World! (215.46 ms)
2. Hello World! (189.13 ms)
3. Hello World! (215.67 ms)
4. Hello World! (219.85 ms)
5. Hello World! (208.47 ms)
6. Hello World! (218.90 ms)
7. Hello World! (218.82 ms)
8. Hello World! (221.22 ms)
9. Hello World! (213.32 ms)
10. Hello World! (225.79 ms)
11. Hello World! (240.56 ms)
12. Hello World! (221.43 ms)
13. Hello World! (225.36 ms)
14. Hello World! (248.18 ms)
15. Hello World! (216.12 ms)
16. Hello World! (248.30 ms)
17. Hello World! (248.37 ms)
18. Hello World! (227.34 ms)
19. Hello World! (216.38 ms)
20. Hello World! (207.62 ms)
```
