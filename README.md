# GKE Demo Using Terraform

## Directions
1. Install the GCP SDK and run the commands to authenticate
1. Setup a GCP Bucket for the Terraform state
1. Install Terraform
1. Run the Terraform code

### Installing Google SDK and Authenticate With Google
```bash
# Follow the instructions here to install the SDK on your workstation
# https://cloud.google.com/sdk/docs/install

# Run the following commands to authenticate once you've installed the SDK
gcloud init
gcloud auth application-default login
```

### Setup GCP Bucket For Terraform State
1. Create a GCP bucket in the google console
1. Make sure that your application user account has access to the bucket


### Installing Terraform
```bash
# From https://learn.hashicorp.com/tutorials/terraform/install-cli
# Assuming Ubuntu Workstation
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
# Install Terraform from the APT repo
sudo apt-get update && sudo apt-get install terraform -y
```

### Downloading, Configuring, and Running The Code
```bash
# Download the code to your workstation
git clone git@github.com:opmode/demo-gke.git terraform; cd terraform

# In the root terraform folder,
# Create a `backend.tf` file so that terraform can use your bucket to keep track of your servers

terraform {
  backend "gcs" {
    bucket  = "your-cluster-demo-tf-state"
    prefix  = "terraform/state"
  }
}

# Run the commands below to apply the Terraform code
# Make sure to substitute the project and CIDR placeholders

# Terraform Dry Run
terraform plan -var="project=YOUR_GCP_PROJECT" -var="admin_ipv4_cidr_block=YOUR_CIDR/32"

# Terraform Apply Changes
terraform apply -var="project=YOUR_GCP_PROJECT" -var="admin_ipv4_cidr_block=YOUR_CIDR/32"

# To Clean up
terraform destroy -var="project=YOUR_GCP_PROJECT" -var="admin_ipv4_cidr_block=YOUR_CIDR/32"


```

### Inspecting Kubernetes
```bash
# Log into Kubernetes
gcloud container clusters get-credentials demo-gke-cluster --zone us-central1-a

# Inspect pod networking on a test pod (should ping out)
kubectl run -i --tty test --image=praqma/network-multitool --restart=Never

# Run the sample service and enable access to it
cd ~/kubernetes-app
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f ingress.yml


```