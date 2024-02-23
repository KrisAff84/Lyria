The Terraform configurations for the Lyria infrastructure is organized into 3 folders for blue/green deployments. Once a configuration has been changed, the DNS routing needs to be changed in the "dns_records" folder.

**Current Version:** Green

## Green Infrastructure 
- Custom VPC
- 2 Public Subnets
- 2 Private Subnets
- Auto Scaling Group in Private Subnets
- Load Balancer in Public Subnets
- Bastion Server (uncomment to provision)

## Blue Infrastructure
Currently, the blue infrastructure does not work. It was my attempt to convert the network to IPv6, but what I didn't realize is that load balancers require IPv4. A new way of reducing cost will have to be considered.

**Possibilities:**
- Django deployment with Lambda using Zappa
- Doing away with load balancer and autoscaling group and using a single IPv6 instance

## dns_records 
Once the new infrastructure is in place, the blue/green deployment can be made be updating the **Route53 records** in the **dns_records** folder. 