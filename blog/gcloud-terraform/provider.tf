provider google {
  version     = "~> 3.9"
  credentials = file("account.json")
  project     = var.projectid
  region      = var.region
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  version = "~> 2.48"
}
