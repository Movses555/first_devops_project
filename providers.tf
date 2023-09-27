# AWS provider
provider "aws" {
  region = "us-east-1"
}

# http provider
equired_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
  }