terraform {
#  backend "http" {
#    address        = "https://api.abbey.io/terraform-http-backend"
#    lock_address   = "https://api.abbey.io/terraform-http-backend/lock"
#    unlock_address = "https://api.abbey.io/terraform-http-backend/unlock"
#    lock_method    = "POST"
#    unlock_method  = "POST"
#  }

  required_providers {
    abbey = {
      source = "abbeylabs/abbey"
      version = "0.2.2"
    }

    github = {
      source = "integrations/github"
      version = "5.28.0"
    }
  }
}

provider "abbey" {
  # Configuration options
  bearer_token = var.abbey_token
}

provider "github" {
  owner = "abbeylabs"
  token = var.token
}

resource "github_team" "pii_team" {
  name = "PIITeam"
  description = "This team has access to PII data."
}

resource "abbey_grant_kit" "engineering_pii_github_team" {
  name = "GitHub Team: Engineering PII"
  description = <<-EOT
    This resource represents a GitHub Team Membership for engineers looking to access PII data.

    This Grant Kit grants access and expires it automatically after 24 hours.
  EOT

  workflow = {
    steps = [
      {
        reviewers = {
          # Replace with your Abbey login, typically your email used to sign up.
          one_of = ["replace-me@example.com"]
        }
      }
    ]
  }

  policies = [
    {
      # Optionally, you can build an OPA bundle and keep it in your repo.
      # `opa build -b policies/common -o policies/common.tar.gz`
      #
      # If you do, you can then specify `bundle` with:
      # bundle = "github://organization/repo/policies/common.tar.gz"
      #
      # Otherwise you can specify the directory. Abbey will build an
      # OPA bundle for you and recursively add all your policies.
      bundle = "github://organization/repo/policies"
    }
  ]

  output = {
    # Replace with your own path pointing to where you want your access changes to manifest.
    # Path is an RFC 3986 URI, such as `github://{organization}/{repo}/path/to/file.tf`.
    location = "github://organization/repo/access.tf"
    append = <<-EOT
      resource "github_team_membership" "gh_mem_{{ .data.system.abbey.secondary_identities.github.username }}" {
        team_id = github_team.pii_team.id
        username = "{{ .data.system.abbey.secondary_identities.github.username }}"
        role = "member"
      }
    EOT
  }
}

resource "abbey_identity" "user_1" {
  name = "replace-me"

  linked = jsonencode({
    abbey = [
      {
        type  = "AuthId"
        value = "replace-me@example.com"
      }
    ]

    github = [
      {
        username = "replaceme"
      }
    ]
  })
}
