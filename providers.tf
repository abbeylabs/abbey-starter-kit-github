provider "abbey" {
  bearer_auth = var.abbey_token
}

provider "github" {
  owner = "replace-me" #CHANGEME
  token = var.token
}
