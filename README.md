# TERRAFORM-S3-SITE-ESTATICO# 
This project is for creating a static s3 website
#### PROVIDERS

| NAME | ALIAS | VERSION |
|------|---------|---------|
|provider_aws |  | 2.70
|provider_aws | origen | 2.70
|provider_aws | destination | 2.70

#### HOW TO USE
```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "default"

}

module "site-estatico"{
name              = "nome-do-seu-site-estático"
environment       = "dev"
log_bucket        = "log-seu-site-estático"
oai_name          = "oai-seu-site-estático"
project           = "seu-site-estático"
domain            = "seu-dominio"
route53_zone_id   = "sua-zone id"
ssl_arn           = "arn do seu certificado"

}
```

