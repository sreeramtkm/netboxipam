# Introduction 
The repo contains terraform code which deploys the community version of netbox IPAM solution.https://netboxlabs.com

# Project Specifics
- The terraform code is meant to deploy the netbox ipam OSS in Azure App services. 
- Azure pipeline is used to deploy the same. 
- The images for the various components for the solution is pulled from the docker registry
- The infrastructure code is split into stateful infra and stateless infra. 
- From a resource group perspective also the stateful part of the infrastructure is in a different resource group.
