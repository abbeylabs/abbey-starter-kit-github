terraform {
  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "~> 0.2.6"
    }

    github = {
      source = "integrations/github"
      version = "~> 5.28.0"
    }
  }
}
