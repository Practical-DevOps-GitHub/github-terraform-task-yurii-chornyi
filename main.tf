provider "github" {
  token = var.github_token
  owner = "yurii-chornyi"
}

resource "github_repository" "repo" {
  name        = "your-repository-name"
  description = "Repository configured with Terraform"
  private     = true
  auto_init   = true
}

resource "github_repository_collaborator" "softservedata" {
  repository = github_repository.repo.name
  username   = "softservedata"
  permission = "push" 
}

resource "github_branch" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"
}

resource "github_repository_branch_protection" "main" {
  repository = github_repository.repo.name
  branch     = "main"

  required_pull_request_reviews {
    dismiss_stale_reviews               = true
    required_approving_review_count     = 1 
  }
  enforce_admins = true
}

resource "github_repository_branch_protection" "develop" {
  repository = github_repository.repo.name
  branch     = "develop"

  required_pull_request_reviews {
    dismiss_stale_reviews               = true
    required_approving_review_count     = 2 
  }
  enforce_admins = true
}

resource "github_codeowners" "main_codeowner" {
  repository = github_repository.repo.name
  codeowners = [ "* @softservedata" ]
}

resource "github_repository_file" "pr_template" {
  repository = github_repository.repo.name
  file       = ".github/pull_request_template.md"
  content    = <<EOF
# Pull Request Template
**Describe your changes:**

**Issue ticket number and link:**

**Checklist before requesting a review:**
- [ ] I have performed a self-review of my code
- [ ] If it is a core feature, I have added thorough tests
- [ ] Do we need to implement analytics?
- [ ] Will this be part of a product update? If yes, please write one phrase about this update
EOF
  branch = "main"
}

resource "github_repository_deploy_key" "deploy_key" {
  repository = github_repository.repo.name
  title      = "DEPLOY_KEY"
  key        = var.deploy_key
  read_only  = false
}

resource "github_repository_webhook" "discord_webhook" {
  repository = github_repository.repo.name
  name       = "web"
  active     = true
  events     = ["pull_request"]
  configuration {
    url          = "https://discord.com/api/webhooks/your_webhook_url"
    content_type = "json"
  }
}

resource "github_actions_secret" "pat" {
  repository   = github_repository.repo.name
  secret_name  = "PAT"
  plaintext_value = var.pat
}

