# azure-infra

# Project Structure

```
infrastructure/
├── env/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── terraform.tfvars
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       └── terraform.tfvars
├── modules/
│   ├── app/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── monitoring/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── .gitignore
└── README.md
```

NOTE:  To apply from scratch follow these steps:
1.  Go to /state folder and apply terraform.  This setups up buckets and remote state
2.  Go to your desired environment (only dev at the moment of writing) and apply from there it should work fine.

Manifest:
- Decoupled state from environments and services
- Remote state setup in BLOB storage
- AKS cluster with spot instances 
