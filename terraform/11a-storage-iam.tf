# In GKE, the Persistent Disk CSI driver is enabled as a cluster add-on.
# There is no direct equivalent to the EKS EBS CSI IAM role pattern here.
#
# This file is preserved to keep the same overall structure as the original
# AWS Terraform layout while shifting storage integration to native GKE methods.

provider "kubernetes" {
  host                   = "https://${google_container_cluster.demo.endpoint}"
  token                  = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.demo.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_storage_class_v1" "premium_rwo" {
  metadata {
    name = "premium-rwo-custom"
  }

  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "pd-ssd"
  }

  depends_on = [
    google_container_cluster.demo,
    google_container_node_pool.private-nodes,
    null_resource.update_kubeconfig
  ]
}