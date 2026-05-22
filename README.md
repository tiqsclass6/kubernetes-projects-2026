# 📽 **Project 2 - Argo CD GitOps Security (Splunk Multi-Environment Deployment)**

![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon EKS](https://img.shields.io/badge/Amazon_EKS-Kubernetes-FF9900?style=for-the-badge&logo=amazoneks&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Argo CD](https://img.shields.io/badge/Argo_CD-v2.12+-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![GitOps](https://img.shields.io/badge/GitOps-Continuous_Delivery-7B42BC?style=for-the-badge&logo=git&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![RBAC](https://img.shields.io/badge/Security-RBAC-2E7D32?style=for-the-badge&logo=auth0&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-0A66C2?style=for-the-badge)

---

## 🧑‍🏫 **Network Architecture Diagram**

![diagram.png](/Screenshots/diagram.png)

---

## 🥼 **Project Overview**

This project demonstrates a **secure GitOps deployment model using Argo CD** on a Kubernetes cluster.

The project simulates a real-world DevOps environment where:

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

This project demonstrates:

- GitOps application lifecycle
- RBAC security enforcement
- Argo CD automation
- Multi-environment deployments
- Kubernetes operational validation

---

## 🥼 **DevOps Skills Demonstrated**

This project demonstrates the following DevOps capabilities:

- **Infrastructure as Code** ➡ *Terraform*  
- **Cloud Platform** ➡ *AWS EKS*  
- **Container Orchestration** ➡ *Kubernetes*  
- **GitOps Deployment** ➡ *Argo CD*  
- **Security Enforcement** ➡ *RBAC Policies*  
- **Environment Isolation** ➡ *Kubernetes Namespaces*  
- **Automation** ➡ *Bash scripting*  
- **Operational Validation** ➡ *automated project status checks*

---

## 🛠️ **Project Requirements**

Before running the project, the following tools must be installed:

| **Tool**        | **Version**            |
|-----------------|------------------------|
| **Kubernetes**  | `1.27+`                |
| **AWS CLI**     | `Latest`               |
| **kubectl**     | `Latest`               |
| **Terraform**   | `1.5+`                 |
| **Argo CD CLI** | `v2.12+`               |
| **Bash**        | `Linux/macOS/Git Bash` |

The cluster used for this project is:

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

![project-requirements.jpg](/Screenshots/project-requirements.jpg)

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

This project implements a **GitOps workflow with Argo CD**.

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

This pattern is widely used in **enterprise GitOps platforms**.

---

## 📁 **Project Structure**

```text
project-2/
│
├── manifests/                                   # GitOps manifests for Argo CD and applications
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
│   │
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
├── Screenshots/                                 # Screenshots of project steps and results
|   ├── argocd-apps-sync.jpg
|   ├── argocd-cluster-state.jpg
|   ├── deploy-script-port-fwd.jpg
|   ├── deploy-script-pt1.jpg
|   ├── deploy-script-pt2.jpg
|   ├── deploy-script-pt3.jpg
|   ├── deploy-script-pt4.jpg
|   ├── deploy-script-pt5.jpg
|   ├── get-secret-command.jpg
|   ├── kubeconfig-get-nodes.jpg
|   ├── project-final-check-pt1.jpg
|   ├── project-final-check-pt2.jpg
|   ├── project-final-check-pt3.jpg
|   ├── project-final-check-pt4.jpg
|   ├── project-requirements.jpg
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
|   ├── terraform-apply.jpg
|   ├── terraform-destroy.jpg
|   ├── terraform-init-fmt-validate.jpg
|   ├── terraform-plan.jpg
|   ├── users-pt1.jpg
|   ├── users-pt2.jpg
|   └── users-pt3.jpg
|
├── scripts/                                     # Automation scripts for project operations
│   ├── 1-deployment.sh
│   ├── 2-rbac.sh
│   ├── 3-users.sh
│   ├── 4-project-final-check.sh
│   └── 5-teardown.sh
│
├── .gitignore                                   # Git ignore file
├── 0-var.tf                                     # Variable definitions for Terraform
├── 1-auth.tf                                    # AWS provider and authentication configuration for Terraform
├── 2-vpc.tf                                     # VPC configuration for Terraform
├── 3-subnets.tf                                 # Subnet configuration for Terraform
├── 4-igw.tf                                     # Internet Gateway configuration for Terraform
├── 5-nat.tf                                     # Elastic IP and NAT Gateway configuration for Terraform
├── 6-rtb.tf                                     # Route Table configuration for Terraform
├── 7-eks.tf                                     # EKS cluster file for Terraform
├── 8-node.tf                                    # Node group configuration for Terraform
├── 9-runtime.tf                                 # Runtime configuration for Terraform (IAM roles, policies, etc.)
├── 10-iam-oidc.tf                               # IAM OIDC provider configuration for Terraform
├── 11a-storage-iam.tf                           # Storage IAM configuration file for Terraform
├── 11b-storage-helm.tf                          # Helm storage configuration for Terraform
├── 12-outputs.tf                                # Output definitions
└── README.md                                    # This file
```

---

## 🛠️ **Terraform Deployment Steps**

Provision infrastructure using Terraform.

> Terraform provisions the AWS infrastructure required for the project, including VPC networking, EKS cluster, node groups, IAM roles, and Kubernetes runtime components.

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

The project environment is automated using several scripts.

### 💻 [**`1-deployment.sh`**](/scripts/1-deployment.sh)

Installs Argo CD and deploys the GitOps environment

```bash
./scripts/1-deployment.sh
```

![deploy-script-pt1.jpg](/Screenshots/deploy-script-pt1.jpg)
![deploy-script-pt2.jpg](/Screenshots/deploy-script-pt2.jpg)
![deploy-script-pt3.jpg](/Screenshots/deploy-script-pt3.jpg)
![deploy-script-pt4.jpg](/Screenshots/deploy-script-pt4.jpg)
![deploy-script-pt5.jpg](/Screenshots/deploy-script-pt5.jpg)

#### **This script performs**

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

### 💻 [**`2-rbac.sh`**](/scripts/2-rbac.sh)

```bash
./scripts/2-rbac.sh
```

RBAC configuration script applies access control policies to Argo CD.

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

### 💻 [**`3-users.sh`**](/scripts/3-users.sh)

Creates project users and configures RBAC access.

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

### 💻 [**`4-lab-final-check.sh`**](/scripts/4-lab-final-check.sh)

Validates the entire environment.

```bash
./scripts/4-lab-final-check.sh
```

![project-final-check-pt1.jpg](/Screenshots/project-final-check-pt1.jpg)
![project-final-check-pt2.jpg](/Screenshots/project-final-check-pt2.jpg)
![project-final-check-pt3.jpg](/Screenshots/project-final-check-pt3.jpg)
![project-final-check-pt4.jpg](/Screenshots/project-final-check-pt4.jpg)

#### **Checks**

- Kubernetes connectivity
- Argo CD pods
- AppProjects
- Applications
- RBAC rules
- local users

---

### 💻 [**`5-teardown.sh`**](/scripts/5-teardown.sh)

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

## 🖼️ **Demo and Artifacts**

### 📦 **Argo CD Deployment Demo**

  <https://github.com/user-attachments/assets/8ff7903a-1010-4696-bec0-e73701660e5e>

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

## 📝 **Project Outcome**

After completing this project the environment contains:

- AWS EKS Kubernetes cluster
- Argo CD GitOps controller
- Three isolated environments (dev/test/prod)
- RBAC enforced user access
- Automated validation scripts

This demonstrates a production-style GitOps deployment model.

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

The following official resources were used to design, build, validate, and document **Project 2: Argo CD GitOps Security project on AWS EKS**.

- [**Argo CD Documentation:**](https://argo-cd.readthedocs.io) Used to understand and configure Argo CD application management, GitOps synchronization, AppProjects, RBAC behavior, and Kubernetes-based Argo CD deployment patterns. This directly supports the Project 2 implementation of Argo CD Applications, AppProjects for `splunk-dev`, `splunk-test`, and `splunk-prod`, and RBAC-based access control.

- [**Argo CD RBAC Configuration Documentation:**](https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/) Used specifically for configuring Argo CD role-based access control through the `argocd-rbac-cm` ConfigMap and Casbin policy syntax. This supports the project requirement where `admin1` has access to all environments while `student1` and `student2` are limited to dev/test access.

- [**AWS EKS Documentation:**](https://docs.aws.amazon.com/eks/) Used to understand the AWS-managed Kubernetes control plane, EKS cluster provisioning, node groups, cluster access, and operational requirements for running Kubernetes workloads on AWS. This supports the Project 2 AWS EKS infrastructure created through Terraform in the `us-east-1` region.

- [**Amazon EKS IAM and Access Documentation:**](https://docs.aws.amazon.com/eks/latest/userguide/security-iam.html) Used to understand IAM integration with Amazon EKS, including cluster permissions, AWS authentication, node role permissions, and secure access patterns. This supports the Terraform files responsible for EKS authentication, IAM roles, node group permissions, and OIDC-related configuration.

- [**Kubernetes Documentation:**](https://kubernetes.io/docs) Used to understand Kubernetes namespaces, deployments, services, RBAC concepts, workload lifecycle, and validation commands. This supports the Project 2 deployment of isolated namespaces for `splunk-dev`, `splunk-test`, and `splunk-prod`, along with Kubernetes resources used to run the Splunk applications.

- [**Kubernetes RBAC Documentation:**](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) Used as a reference for general Kubernetes role-based access control concepts. Although Project 2 focuses on Argo CD RBAC, Kubernetes RBAC concepts help explain how access control, permissions, and authorization are commonly enforced in Kubernetes environments.

- [**Terraform Documentation:**](https://developer.hashicorp.com/terraform) Used to build and validate the Infrastructure as Code workflow for AWS resources. This supports the modular Terraform design used in Project 2, including files for variables, providers, VPC, subnets, internet gateway, NAT gateway, route tables, EKS cluster, node group, OIDC, storage IAM, Helm storage, and outputs.

- [**Terraform AWS Provider Documentation:**](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) Used to reference AWS resource syntax and configuration patterns for Terraform-managed infrastructure. This supports the AWS resources created in Project 2, including VPC networking, EKS, IAM, node groups, and related infrastructure components.

- [**Project 2 GitHub Repository:**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-2) Used as the source repository for the project implementation, project structure, Terraform files, Kubernetes manifests, automation scripts, screenshots, and README documentation. The Project 2 branch contains the Argo CD GitOps Security Project with Splunk multi-environment deployment, RBAC enforcement, and AWS EKS infrastructure.

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

## 👥 **Author**

| **Field**        | **Value**                                  |
| ---------------- | ------------------------------------------ |
| **Author**       | `T.I.Q.S.`                                 |
| **Group Leader** | `John Sweeney`                             |
| **Group Name**   | `The Brotherhood of jerMutants - Wolfpack` |
| **Version**      | `v1.4`                                     |
| **Date**         | `March 12, 2026`                           |
