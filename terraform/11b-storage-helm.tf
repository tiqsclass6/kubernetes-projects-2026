# No Helm deployment is required for the GKE PD CSI driver.
# This file remains in place to mirror the EKS source structure.
# A second StorageClass is created here as the closest structural equivalent.

resource "kubernetes_storage_class_v1" "standard_rwo" {
  metadata {
    name = "standard-rwo-custom"
  }

  storage_provisioner    = "pd.csi.storage.gke.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "pd-balanced"
  }

  depends_on = [
    google_container_cluster.demo,
    google_container_node_pool.private-nodes,
    null_resource.update_kubeconfig
  ]
}