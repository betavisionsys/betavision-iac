terraform {
  backend "s3" {
    bucket = "meu-tfstate"
    key    = "clienteA/terraform.tfstate"
    region = "us-east-1"
  }
}
