# Lyria Infrastructure

The Terraform configurations for the Lyria infrastructure is organized into multiple folders for blue/green deployments. Once a configuration has been changed, the DNS routing needs to be changed in the "dns_records" folder.

**Current Version:** Blue

## Blue Infrastructure

TODO: Add blue infrastructure, include a diagram

## dns_records

Once the new infrastructure is in place, the blue/green deployment can be made be updating the **Route53 records** in the **dns_records** folder.
