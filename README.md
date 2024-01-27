# kaniko-tst

My Kaniko testing repo

export TF_LOG=DEBUG
terraform apply

```bash
kubectl create secret docker-registry acr-auth --docker-server=acrtechlab01.azurecr.io --docker-username=acrtechlab01 --docker-password=nPPWtNnVRMUAALMhuBIM2tj --namespace=tun
```

***Important:***

- Terraform doest not require base64 encoding for the secret value. It will do it for you.
