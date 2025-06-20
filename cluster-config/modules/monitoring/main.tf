# Install Kube-prometheus-stack
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version
  namespace  = var.namespace

  values = [
    templatefile("${path.module}/helm/prometheus-values.yaml.tmpl", {
      grafana_admin_password = var.grafana_admin_password
    })
  ]

  timeout      = 600
  force_update = true
  reuse_values = true
}

# Create custom Grafana dashboards
resource "kubernetes_config_map" "grafana_dashboards" {
  metadata {
    name      = "custom-grafana-dashboards"
    namespace = "monitoring"
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "kubernetes-dashboard.json"    = file("${path.module}/helm/dashboards/kubernetes-dashboard.json")
    "node-exporter-dashboard.json" = file("${path.module}/helm/dashboards/node-exporter-dashboard.json")
    "prometheus-dashboard.json"    = file("${path.module}/helm/dashboards/prometheus-dashboard.json")
    "sockshop-dashboard.json"      = file("${path.module}/helm/dashboards/sockshop-dashboard.json")
  }
}
