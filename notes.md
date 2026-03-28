terraform init

terraform fmt 

terraform validate

terraform plan


# A partir da raiz do projeto Lamda (terraform-code)
terraform -chdir=lambda init

terraform -chdir=lambda validate

terraform -chdir=lambda apply