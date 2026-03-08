# 📽 **Project 2 - Argo CD GitOps Security Lab (Splunk Multi-Environment Deployment)**

![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-blue?logo=kubernetes)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-orange?logo=argo)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-black?logo=amazonaws)
![Security](https://img.shields.io/badge/Security-RBAC-green)
![Argo CD](https://img.shields.io/badge/ArgoCD-v2.12+-blue)
![GitHub](https://img.shields.io/badge/GitHub-Repo-black?logo=github)

---

## 🥼 **Lab Overview**

This project demonstrates a **secure GitOps deployment model using Argo CD** on a Kubernetes cluster.

The lab simulates a real-world DevOps environment where:

- Multiple environments are deployed
- Access is restricted using RBAC
- Applications are managed via GitOps
- Infrastructure lifecycle is automated

The system deploys a **Splunk application across three environments**:

| **Environment** | **Namespace**     | **Project**     |
|-----------------|-------------------|-----------------|
| **Production**  | `splunk-prod`     | `splunk-prod`   |
| **Development** | `splunk-dev`      | `splunk-dev`    |
| **Testing**     | `splunk-test`     | `splunk-test`   |

Access policies enforce **environment isolation**:

| **User**     | **Role**            | **Access**          |
|--------------|---------------------|---------------------|
| **admin1**   | `admin`             | `prod + dev + test` |
| **student1** | `dev/test operator` | `dev + test only`   |
| **student2** | `dev/test operator` | `dev + test only`   |

This lab demonstrates:

- GitOps application lifecycle
- RBAC security enforcement
- Argo CD automation
- multi-environment deployments
- Kubernetes operational validation

---

## 🛠️ **Lab Requirements**

Before running the lab, the following tools must be installed:

| **Tool**        | **Version**            |
|-----------------|------------------------|
| **Kubernetes**  | `1.27+`                |
| **AWS CLI**     | `Latest`               |
| **kubectl**     | `Latest`               |
| **Terraform**   | `1.5+`                 |
| **Argo CD CLI** | `v2.12+`               |
| **Bash**        | `Linux/macOS/Git Bash` |

The cluster used for this lab is:

```text
AWS EKS
Region: us-east-1
Cluster: demo
```

Verify access:

```bash
kubectl cluster-info
kubectl get nodes
```

![lab-requirements.jpg](/Screenshots/lab-requirements.jpg)

---

## 🎤 **Interview Talk Track**

### **Business Explanation**

This project demonstrates how organizations can deploy applications **securely and consistently across multiple environments** using GitOps.

Benefits include:

- Controlled deployments
- Reduced configuration drift
- Automated application lifecycle
- Environment isolation
- Secure developer access controls

In enterprise environments this pattern enables teams to deploy software faster while maintaining governance and security.

---

### **DevOps / Technical Explanation**

This lab implements a **GitOps workflow with Argo CD**.

Key components include:

- Argo CD managing Kubernetes deployments from Git
- AppProjects used for environment isolation
- RBAC policies controlling user permissions
- Terraform provisioning infrastructure
- Bash automation scripts orchestrating lifecycle operations

Each environment is isolated using:

- Kubernetes namespaces
- Argo CD AppProjects
- RBAC policy enforcement

The workflow looks like:

```text
Git Repo
   │
   ▼
Argo CD
   │
   ▼
Kubernetes Cluster
   │
   ├── splunk-dev
   ├── splunk-test
   └── splunk-prod
```

This pattern is widely used in **enterprise GitOps platforms**.

---

## 📁 **Project Structure**

```text
project-2/
│
├── manifests/                                                                # GitOps manifests for Argo CD and applications
│   ├── rbac/
│   │   └── argocd-rbac-cm.yaml
│   │
│   ├── securitylab/
│   │   ├── argoproject-splunk-dev.yaml
│   │   ├── argoproject-splunk-test.yaml
│   │   └── argoproject-splunk-prod.yaml
│   │
│   ├── splunk/
│   │   ├── base/
│   │   │   ├── deployment.yaml
│   │   │   ├── kustomization.yaml
│   │   │   └── service.yaml
│   │   └── overlays/
│   │       ├── dev/
│   │       │   ├── deployment.yaml
│   │       │   └── kustomization.yaml
│   │       └── test/
│   │           ├── deployment.yaml
│   │           └── kustomization.yaml
|   │
│   ├── argocd-controller.yaml
│   ├── argocd-deploy.yaml
│   ├── argocd-namespace.yaml
│   ├── argocd-port.yaml
│   ├── argocd-redis.yaml
│   ├── argocd-repo.yaml
│   ├── splunk-dev-app.yaml
│   ├── splunk-prod-app.yaml
│   └── splunk-test-app.yaml
|
├── Screenshots/                                                              # Screenshots of lab steps and results
|   ├── argocd-apps-sync.jpg
|   ├── argocd-cluster-state.jpg
|   ├── deploy-script-port-fwd.jpg
|   ├── deploy-script-pt1.jpg
|   ├── deploy-script-pt2.jpg
|   ├── deploy-script-pt3.jpg
|   ├── deploy-script-pt4.jpg
|   ├── deploy-script-pt5.jpg
|   ├── lab-final-check-pt1.jpg
|   ├── lab-final-check-pt2.jpg
|   ├── lab-final-check-pt3.jpg
|   ├── lab-final-check-pt4.jpg
|   ├── lab-requirements.jpg
|   ├── rbac-pt1.jpg
|   ├── rbac-pt2.jpg
|   ├── rbac-pt3.jpg
|   ├── splunk-dev-appproject.jpg
|   ├── splunk-dev-details.jpg
|   ├── splunk-dev-tree.jpg
|   ├── splunk-prod-appproject.jpg
|   ├── splunk-prod-details.jpg
|   ├── splunk-prod-tree.jpg
|   ├── splunk-test-appproject.jpg
|   ├── splunk-test-details.jpg
|   ├── splunk-test-tree.jpg
|   ├── splunk-user-accounts.jpg
|   ├── teardown-pt1.jpg
|   ├── teardown-pt2.jpg
|   ├── teardown-pt3.jpg
|   ├── users-pt1.jpg
|   ├── users-pt2.jpg
|   ├── users-pt3.jpg
|   ├── terraform-apply.jpg
|   ├── terraform-destroy.jpg
|   ├── terraform-init-fmt-validate.jpg
|   ├── terraform-plan.jpg
|   ├── users-pt1.jpg
|   ├── users-pt2.jpg
|   └── users-pt3.jpg
|
├── scripts/                                                                  # Automation scripts for lab operations
│   ├── 1-deployment.sh
│   ├── 2-rbac.sh
│   ├── 3-users.sh
│   ├── 4-lab-final-check.sh
│   └── 5-teardown.sh
│
├── .gitignore                                                                # Git ignore file
├── 0-var.tf                                                                  # Variable definitions for Terraform
├── 1-auth.tf                                                                 # AWS provider and authentication configuration for Terraform
├── 2-vpc.tf                                                                  # VPC configuration for Terraform
├── 3-subnets.tf                                                              # Subnet configuration for Terraform
├── 4-igw.tf                                                                  # Internet Gateway configuration for Terraform
├── 5-nat.tf                                                                  # Elastic IP and NAT Gateway configuration for Terraform
├── 6-rtb.tf                                                                  # Route Table configuration for Terraform
├── 7-eks.tf                                                                  # EKS cluster file for Terraform
├── 8-node.tf                                                                 # Node group configuration for Terraform
├── 9-runtime.tf                                                              # Runtime configuration for Terraform (IAM roles, policies, etc.)
├── 10-iam-oidc.tf                                                            # IAM OIDC provider configuration for Terraform
├── 11a-storage-iam.tf                                                        # Storage IAM configuration file for Terraform
├── 11b-storage-helm.tf                                                       # Helm storage configuration for Terraform
├── 12-outputs.tf                                                             # Output definitions
└── README.md                                                                 # This file
```

---

## 🛠️ **Terraform Deployment Steps**

Provision infrastructure using Terraform.

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

![terraform-init-fmt-validate.jpg](/Screenshots/terraform-init-fmt-validate.jpg)
![terraform-plan.jpg](/Screenshots/terraform-plan.jpg)
![terraform-apply.jpg](/Screenshots/terraform-apply.jpg)

After Terraform finishes, configure kubeconfig:

```bash
aws eks update-kubeconfig \
--region us-east-1 \
--name demo
```

Verify cluster connectivity:

```bash
kubectl get nodes
```

![kubeconfig-get-nodes.jpg](/Screenshots/kubeconfig-get-nodes.jpg)

---

## 📝 **Shell Scripts**

The lab environment is automated using several scripts.

### 💻 1. **`1-deployment.sh`**

#### Installs Argo CD and deploys the GitOps environment

```bash
./scripts/1-deployment.sh
```

![deploy-script-pt1.jpg](/Screenshots/deploy-script-pt1.jpg)
![deploy-script-pt2.jpg](/Screenshots/deploy-script-pt2.jpg)
![deploy-script-pt3.jpg](/Screenshots/deploy-script-pt3.jpg)
![deploy-script-pt4.jpg](/Screenshots/deploy-script-pt4.jpg)
![deploy-script-pt5.jpg](/Screenshots/deploy-script-pt5.jpg)

This script performs:

- Argo CD installation
- AppProject deployment
- RBAC configuration
- Splunk application deployment

#### **Get secret for admin password**

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode; echo 
```

![get-secret-command.jpg](/Screenshots/get-secret-command.jpg)

#### **Port Forward Argo CD server**

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

![deploy-script-port-fwd.jpg](/Screenshots/deploy-script-port-fwd.jpg)

#### **Login to Argo CD UI**

```text
https://localhost:8080
```

![argocd-apps-sync.jpg](/Screenshots/argocd-apps-sync.jpg)

---

### 💻 2. **`2-rbac.sh`**

```bash
./scripts/2-rbac.sh
```

![rbac-pt1.jpg](/Screenshots/rbac-pt1.jpg)
![rbac-pt2.jpg](/Screenshots/rbac-pt2.jpg)
![rbac-pt3.jpg](/Screenshots/rbac-pt3.jpg)

#### **This script applies the RBAC configuration**

- Creates `argocd-rbac-cm` ConfigMap
- Defines roles and permissions for `admin1`, `student1`, and `student2`
- Enforces environment isolation based on user roles
- Verifies RBAC policies are applied correctly
- Tests access controls using `argocd` CLI commands

---

### 💻 3. **`3-users.sh`**

Creates lab users and configures RBAC access.

```bash
./scripts/3-users.sh
```

![users-pt1.jpg](/Screenshots/users-pt1.jpg)
![users-pt2.jpg](/Screenshots/users-pt2.jpg)
![users-pt3.jpg](/Screenshots/users-pt3.jpg)

#### **Creates users**

```text
admin1
student1
student2
```

Passwords are securely stored using **bcrypt hashes**.

---

### 💻 4. **`4-lab-final-check.sh`**

Validates the entire environment.

```bash
./scripts/4-lab-final-check.sh
```

![lab-final-check-pt1.jpg](/Screenshots/lab-final-check-pt1.jpg)
![lab-final-check-pt2.jpg](/Screenshots/lab-final-check-pt2.jpg)
![lab-final-check-pt3.jpg](/Screenshots/lab-final-check-pt3.jpg)
![lab-final-check-pt4.jpg](/Screenshots/lab-final-check-pt4.jpg)

#### **Checks**

- Kubernetes connectivity
- Argo CD pods
- AppProjects
- Applications
- RBAC rules
- local users

---

### 💻 5. **`5-teardown.sh`**

Removes all GitOps resources.

*See proof in Teardown Steps section below.*

```bash
./scripts/5-teardown.sh
```

This removes:

- Argo CD
- applications
- namespaces
- RBAC policies
- local users

---

## 🖼️ **Artifacts and Screenshots**

### 🖥️ **Cluster State**

![argocd-cluster-state.jpg](/Screenshots/argocd-cluster-state.jpg)

### 🔌 **Port Forwarding**

![deploy-script-port-fwd.jpg](/Screenshots/deploy-script-port-fwd.jpg)

---

### 📁 **App Projects**

- **splunk-dev**
  ![splunk-dev-appproject.jpg](/Screenshots/splunk-dev-appproject.jpg)

- **splunk-prod**
  ![splunk-prod-appproject.jpg](/Screenshots/splunk-prod-appproject.jpg)

- **splunk-test**
  ![splunk-test-appproject.jpg](/Screenshots/splunk-test-appproject.jpg)

### 🌳 **Application Trees**

- **splunk-dev**
  ![splunk-dev-tree.jpg](/Screenshots/splunk-dev-tree.jpg)

- **splunk-prod**
  ![splunk-prod-tree.jpg](/Screenshots/splunk-prod-tree.jpg)

- **splunk-test**
  ![splunk-test-tree.jpg](/Screenshots/splunk-test-tree.jpg)

### 📝 **Application Details**

- **splunk-dev**
  ![splunk-dev-details.jpg](/Screenshots/splunk-dev-details.jpg)

- **splunk-prod**
  ![splunk-prod-details.jpg](/Screenshots/splunk-prod-details.jpg)

- **splunk-test**
  ![splunk-test-details.jpg](/Screenshots/splunk-test-details.jpg)

---

### 👥 **User Accounts**

![splunk-user-accounts.jpg](/Screenshots/splunk-user-accounts.jpg)

---

## 🛠️ **Teardown Steps**

### 🧹 **Clean the environment**

```bash
./scripts/5-teardown.sh
```

![teardown-pt1.jpg](/Screenshots/teardown-pt1.jpg)
![teardown-pt2.jpg](/Screenshots/teardown-pt2.jpg)
![teardown-pt3.jpg](/Screenshots/teardown-pt3.jpg)

### 💣 **Then destroy infrastructure**

```bash
terraform destroy
```

![terraform-destroy.jpg](/Screenshots/terraform-destroy.jpg)

---

## 📚 **References**

- [**Argo CD Documentation**](https://argo-cd.readthedocs.io)
- [**AWS EKS Documentation**](https://docs.aws.amazon.com/eks/)
- [**Kubernetes Documentation**](https://kubernetes.io/docs)
- [**Terraform Documentation**](https://developer.hashicorp.com/terraform)

---

## 🛠️ **Troubleshooting**

### 🔑 **Argo CD login issues**

Ensure port forwarding is active:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Access UI:

```text
https://localhost:8080
```

---

### ⚠️ **Applications stuck in Unknown**

Run:

```bash
argocd app sync splunk-dev splunk-prod splunk-test
```

---

### 🏷️ **Namespace not created**

Verify Application configuration:

```bash
kubectl -n argocd get applications -o yaml
```

---

### 🔐 **RBAC issues**

Verify RBAC policy:

```bash
kubectl -n argocd get cm argocd-rbac-cm -o yaml
```

---

## 👥 **Authors**

- **Author:** T.I.Q.S.
- **Group Leader:** John Sweeney
