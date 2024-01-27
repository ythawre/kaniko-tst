provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "docker-desktop"
}

# Creation of Kubernetes Namespace
resource "kubernetes_namespace" "tun" {
  metadata {
    name = "tun"
  }
}

# Creation of Kubernetes Secret
# export TF_VAR_acr_password="your_acr_password"
resource "kubernetes_secret" "docker_config" {
  metadata {
    name      = "acr-auth"
    namespace = "tun"
  }

  data = {
    ".dockerconfigjson" = file("./acr-auth.json")
  }

  type = "kubernetes.io/dockerconfigjson"
}

variable "git_pat" {
  description = "Personal Access Token for Git"
  type        = string
  sensitive   = true
}

resource "kubernetes_secret" "git_pat" {
  metadata {
    name      = "git-pat"
    namespace = "tun"
  }

  data = {
    "GIT_PAT" = var.git_pat
  }
}

resource "kubernetes_job" "kaniko" {
  metadata {
    name      = "kaniko-job"
    namespace = "default" # Change this to your namespace
  }

  spec {
    template {
      metadata {
        name = "kaniko"
      }

      spec {
        container {
          name  = "kaniko"
          image = "gcr.io/kaniko-project/executor:latest"
          args = [
            "--context=https://github.com/ythawre/kaniko-tst.git#refs/heads/main", # Adjust the branch if necessary
            "--dockerfile=/workspace/Dockerfile",
            "--destination=acrtechlab01.azurecr.io/azdoagent-tst:01",
            "--verbosity=debug"
          ]

          env {
            name = "GIT_PAT"
            value_from {
              secret_key_ref {
                name = "git-pat"
                key  = "GIT_PAT"
              }
            }
          }

          volume_mount {
            name       = "docker-config"
            mount_path = "/kaniko/.docker/"
          }
        }

        restart_policy = "Never"

        volume {
          name = "docker-config"

          secret {
            secret_name = "acr-auth"
          }
        }
      }
    }

    backoff_limit = 2
  }
}


