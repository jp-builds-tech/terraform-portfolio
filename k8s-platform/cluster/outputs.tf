output "cluster_name" {
  description = "Name of the kind cluster."
  value       = kind_cluster.this.name
}

output "kubeconfig_path" {
  description = "Path to the kubeconfig file for the cluster."
  value       = kind_cluster.this.kubeconfig_path
}

output "endpoint" {
  description = "API server endpoint of the cluster."
  value       = kind_cluster.this.endpoint
}
