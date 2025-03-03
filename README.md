# Sample 3tier app
This repo contains code for a Node.js multi-tier application and infrastucture to deploy EKS and RDS instance


```

[EKS CLUSTER]      [RDS INSTANCE]
web <=> api   <=>       db
```

The folders `applications/web` and `applications/api` respectively describe how to install and run each app.


Here is how to deploy the infrastucture and deploy the application....

The Terraform infrastructure is being deployed with the github workflow pipeline:

```
.github/workflows/deploy-infra.yml
```

The node application is first being build using dockerfile, the image pushed to ECR then the application packed using helm and deployed to EKS cluster

```
.github/workflows/deploy-app.yml
```

```
./test-app
```

is the directory of the working application.