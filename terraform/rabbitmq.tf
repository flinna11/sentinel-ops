# 1. Install the Operator (The Foreman)
resource "helm_release" "rabbitmq_operator" {
  name             = "rabbitmq-operator"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "rabbitmq-cluster-operator"
  namespace        = "rabbitmq-system"
  create_namespace = true
  timeout          = 600

  set = [
    { name = "global.imageRegistry", value = "public.ecr.aws" },
    { name = "global.security.allowInsecureImages", value = "true" }
  ]
}

# 2. Deploy the 3-Node Cluster (The Blueprint)
resource "kubernetes_manifest" "rabbitmq_cluster" {
  manifest = {
    apiVersion = "rabbitmq.com/v1beta1"
    kind       = "RabbitmqCluster"
    metadata = {
      name      = "production-rabbitmq"
      namespace = "rabbitmq-system"
    }
    spec = {
      replicas = 3
      image    = "public.ecr.aws/bitnami/rabbitmq:4.1.3-debian-12-r1"
      
      persistence = {
        storageClassName = "" # Essential for your current setup
        storage          = "2Gi"
      }

      resources = {
        requests = { cpu = "500m", memory = "1Gi" }
        limits   = { cpu = "1", memory = "2Gi" }
      }
    }
  }

  depends_on = [helm_release.rabbitmq_operator]
}
