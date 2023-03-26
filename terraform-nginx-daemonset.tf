#---------------------------------------------------(Select Kubernetes As Provider)
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kubernetes-admin@cluster.local"
}
#---------------------------------------------------(Create "terraform-test-ns" name space)
resource "kubernetes_namespace" "terraform-test-ns" {
  metadata {
    annotations = {
      name = "terraform-test-ns"
    }

    labels = {
      mylabel = "terraform-test-ns"
    }

    name = "terraform-test-ns"
  }
}
#----------------------------------------------------(Create Daemonset Resource)
resource "kubernetes_daemon_set_v1" "nginx-daemonset" {
  metadata {
    name      = "terraform-nginx-daemonset"
    namespace = "terraform-test-ns"
    labels = {
      test = "nginx-daemonset-label"
    }
  }

  spec {
    selector {
      match_labels = {
        app = "nginx-daemonset-label"
      }
    }

    template {
      metadata {
        labels = {
         app = "nginx-daemonset-label"
        }
      }

      spec {
        container {
          image = "${var.image-name}"
          name  = "${var.container-name}"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }

        }
      }
    }
  }
}