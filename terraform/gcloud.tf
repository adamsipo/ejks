terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.16.0" # celkom uzitocne ak chces aby to bolo kompatiblne s inymi verziami 5.16.x - 5.17.0
    }
  }
}

provider "google" {
  project = var.config["project"]
  region  = var.config["location"]
}
