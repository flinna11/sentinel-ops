#!/bin/bash
export PM_SKIP_PERMISSION_CHECK=1
terraform apply -var-file="secret.tfvars"
