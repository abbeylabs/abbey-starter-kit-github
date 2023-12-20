locals {
  account_name = ""
  repo_name = ""

  project_path = "github://${local.account_name}/${local.repo_name}"
  policies_path = "${local.project_path}/policies"
}

resource "github_team" "abbey_test_team" {
  name = "AbbeyTestTeam"
  description = "This team is testing Abbey."
}

resource "abbey_grant_kit" "engineering_abbey_test_github_team" {
  name = "GitHub_Team_Abbey_Test"
  description = <<-EOT
    This resource represents a GitHub Team Membership for engineers looking to test Abbey.

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
    { bundle = local.policies_path }
  ]

  output = {
    location = "${local.project_path}/access.tf"
    append = <<-EOT
      resource "github_team_membership" "gh_mem_{{ .user.github.username }}" {
        team_id = github_team.abbey_test_team.id
        username = "{{ .user.github.username }}"
        role = "member"
      }
    EOT
  }
}
