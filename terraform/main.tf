# Service Account privs:
#   - roles/owner

# Enable APIs
module "project-services" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 14.4" # aj tuto to pouzivaju rovnako

  project_id = var.config["project"]

  activate_apis = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "compute.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com"
  ]
}

# Image registry
resource "google_artifact_registry_repository" "binary-store" {
  repository_id = "binary-store"
  format        = "DOCKER"

  depends_on = [module.project-services]
}

# Cloud Build trigger
resource "google_cloudbuild_trigger" "github-pull-request" {
  name     = "on-pull-request"
  filename = "cloudbuild-devel.yaml"

  github {
    owner = "stanislavbebej"
    name  = "ejks"
    pull_request {
      branch = "^master$"
          }
  }

  include_build_logs = "INCLUDE_BUILD_LOGS_WITH_STATUS"

  depends_on = [module.project-services]
}

# Cloud Run
resource "google_cloud_run_service" "default" {
  name     = "ejks-sk"
  location = var.config["location"]

  template {
    spec {
      containers {
        image = "${var.config["location"]}-docker.pkg.dev/${var.config["project"]}/binary-store/ejks-image:latest"
        ports {
          container_port = 80
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [module.project-services]
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
