provider "aws" {
  region  = "us-east-1"
  profile = var.profile
  version = "~> 2.48"
}

provider "random" {
  version = "~> 2.2"
}


