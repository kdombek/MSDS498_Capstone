
docker build . -t prodigy:v1

docker tag prodigy:v1 myprodigyacr787.azurecr.io/prodigy:v1
#show images after tag
docker images

#create resource group for demo
az group create --name prodigy-container-demo --location westus2

az group list

#creates container registry



#log into container registry
az acr login --name myprodigyacr787

#push the container to azure registry. this takes time to upload
docker push myprodigyacr787.azurecr.io/prodigy:v1
#show image in registry
az acr repository list --name myprodigyacr787 --output table

# step create K8s cluster. this could take some time
az aks create --resource-group prodigy-container-demo --name AKSprodigy --node-count 1 --enable-addons monitoring --generate-ssh-keys

#need credentials setup.
az aks get-credentials --resource-group prodigy-container-demo --name AKSprodigy
#verify conn
kubectl get nodes
#get service account info: gives alpha numeric string
az aks show --resource-group prodigy-container-demo --name AKSprodigy --query "servicePrincipalProfile.clientId"
#

az acr show --name myprodigyacr787 --resource-group prodigy-container-demo --query "id" --output tsv
#set environment variable
ACR_ID=$(az acr show --name myprodigyacr787 --resource-group prodigy-container-demo --query "id" --output tsv)

az role assignment create --assignee <INSERT SERVICE PRINCIPLE ID> --role acrpull --scope $ACR_ID

# one of these will deploy the container to the cluster this takes time
kubectl apply -f prodigyAKSdeploy.yaml
# list pods. needs status = running when all is deployed
kubectl get pods

kubectl get services

# this will expose the running container as a service
kubectl expose deployment/prodigy
kubectl get services

#adds html external route to cluster
az aks enable-addons --resource-group prodigy-container-demo --name AKSprodigy --addons http_application_routing
kubectl get pods --all-namespaces

#add ingress rules for external facing ip
kubectl apply -f ingress.yaml
kubectl get services

#this will delete the resource group and stop all resources
#az group delete --name prodigy-container-demo --yes --no-wait
