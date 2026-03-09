# 📽 **Project 3 – OPA Gatekeeper + Argo CD (Kubernetes Policy Enforcement)**

![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-blue?logo=kubernetes)
![OPA](https://img.shields.io/badge/Policy-OPA%20Gatekeeper-purple)
![Security](https://img.shields.io/badge/Security-Admission%20Control-green)
![GitOps](https://img.shields.io/badge/GitOps-ArgoCD-orange)
![Terraform](https://img.shields.io/badge/IaC-Terraform-purple?logo=terraform)
![Rego](https://img.shields.io/badge/Policy%20Language-Rego-blue?logo=openpolicyagent)
![Splunk](https://img.shields.io/badge/Monitoring-Splunk-green?logo=splunk)
![Testing](https://img.shields.io/badge/Testing-Automated%20Scripts-yellow)
![AWS](https://img.shields.io/badge/Cloud-AWS-black?logo=amazonaws)
![DevSecOps](https://img.shields.io/badge/Practice-DevSecOps-red)
![License](https://img.shields.io/badge/License-MIT-blue)
![GitHub](https://img.shields.io/badge/GitHub-Repo-black?logo=github)

---

## 🧪 **Lab Overview**

This project demonstrates **OPA Gatekeeper (Kubernetes Policy Enforcement) integrated with a GitOps workflow using Argo CD.** The lab simulates a **secure multi-environment platform** where applications are deployed through GitOps while **admission policies enforce strict environment rules.**

### 💡 **Key goals**

* Prevent misconfigured deployments
* Enforce environment isolation
* Validate service exposure rules
* Demonstrate **DevSecOps runtime policy enforcement**

The system deploys a **Splunk application across three environments**:

| **Environment** | **Namespace** |
| --------------- | ------------- |
| **Production**  | `splunk-prod` |
| **Testing**     | `splunk-test` |
| **Development** | `splunk-dev`  |

---

## 🔐 **Security Policies Enforced**

Gatekeeper enforces the following policies:

### 1️⃣ Argo CD Environment Namespace Lock

Each Argo CD Application must deploy only to its correct namespace.

| **App**         | **Allowed Namespace** |
| --------------- | --------------------- |
| **splunk-prod** | **splunk-prod**       |
| **splunk-test** | **splunk-test**       |
| **splunk-dev**  | **splunk-dev**        |

Example violation:

```text
DENY: ArgoCD Application env=prod must deploy only to namespace splunk-prod
```

---

### 2️⃣ Splunk Service Port Enforcement

Each namespace requires a **specific service port**.

| **Namespace**   | **Required Port** |
| --------------- | ----------------- |
| **splunk-prod** | **8091**          |
| **splunk-test** | **18091**         |
| **splunk-dev**  | **28091**         |

Example violation:

```text
DENY: Service splunk in namespace splunk-prod must expose port 8091
```

---

## 🧠 **DevSecOps Skills Demonstrated**

This lab demonstrates real enterprise platform skills:

| **Category**                | **Skills**               |
| --------------------------- | ------------------------ |
| **Infrastructure as Code**  | `Terraform`              |
| **Cloud Platform**          | `AWS EKS`                |
| **Container Orchestration** | `Kubernetes`             |
| **GitOps**                  | `Argo CD`                |
| **Security**                | `OPA Gatekeeper`         |
| **Policy as Code**          | `Rego`                   |
| **Runtime Security**        | `Admission Controllers`  |
| **Automation**              | `Bash`                   |
| **Validation**              | `Automated test scripts` |

---

## 🏗 **Architecture Overview**

```mermaid
flowchart TB

%% ===============================
%% STYLES
%% ===============================
classDef gitops fill:#1f2937,color:#ffffff,stroke:#111827,stroke-width:1.5px;
classDef argocd fill:#f59e0b,color:#111827,stroke:#b45309,stroke-width:1.5px;
classDef security fill:#7c3aed,color:#ffffff,stroke:#5b21b6,stroke-width:1.5px;
classDef cluster fill:#0ea5e9,color:#ffffff,stroke:#0369a1,stroke-width:1.5px;
classDef app fill:#16a34a,color:#ffffff,stroke:#166534,stroke-width:1.5px;

%% ===============================
%% GITOPS SOURCE
%% ===============================
subgraph GITOPS["GitOps Source of Truth"]
    A[GitHub Repository<br/>Project-3 Branch / Manifests]
end

%% ===============================
%% DELIVERY LAYER
%% ===============================
subgraph DELIVERY["GitOps Delivery Layer"]
    B[Argo CD Controller]
    B1[Argo CD Applications<br/>splunk-dev<br/>splunk-test<br/>splunk-prod]
end

%% ===============================
%% POLICY ENFORCEMENT
%% ===============================
subgraph POLICY["Policy Enforcement Layer"]
    C[OPA Gatekeeper]
    D[ConstraintTemplates<br/>K8sArgoAppEnvironment<br/>K8sServicePortByEnv]
    E[Constraints<br/>argo-app-env-namespace-lock<br/>splunk-service-port-lock]
end

%% ===============================
%% KUBERNETES CLUSTER
%% ===============================
subgraph CLUSTER["AWS EKS Kubernetes Cluster"]
    subgraph NS1["splunk-dev Namespace"]
        F1[Splunk Dev Workload]
    end

    subgraph NS2["splunk-test Namespace"]
        G1[Splunk Test Workload]
    end

    subgraph NS3["splunk-prod Namespace"]
        H1[Splunk Prod Workload]
    end
end

%% ===============================
%% FLOWS
%% ===============================
A -->|GitOps Sync Source| B
B -->|Manages| B1

C -->|Loads Policy Logic| D
D -->|Instantiates Rules| E

B1 -->|Admission Review| C
E -->|Enforces Namespace + Port Rules| B1

B1 -->|Deploys Approved Resources| F1
B1 -->|Deploys Approved Resources| G1
B1 -->|Deploys Approved Resources| H1

%% ===============================
%% CLASS ASSIGNMENTS
%% ===============================
class A gitops;
class B,B1 argocd;
class C,D,E security;
class F1,G1,H1 app;
class F1,G1,H1 cluster;
```

---

## 🎤 **Interview Talk Track**

### 1️⃣ **Business Explanation**

Organizations must ensure **deployment security and governance** in modern cloud environments.

This project demonstrates how **GitOps deployment pipelines can be secured using runtime policy enforcement**.

Benefits include:

* Secure environment isolation
* Automatic policy validation
* Prevent misconfigurations
* Enforce compliance
* Improve deployment safety

This approach reflects **modern enterprise Kubernetes platform security practices.**

---

### 2️⃣ 🛠 **DevOps / Technical Explanation**

This environment integrates:

* **Terraform** provisioning AWS infrastructure
* **Kubernetes** for orchestration
* **Argo CD** for GitOps deployment
* **OPA Gatekeeper** enforcing admission control policies
* **Rego** for defining policies as code
* **Bash** for automation
* **Automated tests** for validation

Policies are defined as **ConstraintTemplates using Rego** and enforced at runtime through the Kubernetes API server admission chain.

This ensures that **any invalid deployment is rejected before it reaches the cluster.**

---

## 📁 **Project Structure**

```text
project-3/
├── homework/
│   ├── 00-namespaces.yaml
│   ├── 10-template-argo-app-env-namespace.yaml
│   ├── 11-constraint-argo-app-env-namespace.yaml
│   ├── 20-template-splunk-service-port-by-env.yaml
│   ├── 21-constraint-splunk-service-port-by-env.yaml
│   ├── 30-app-splunk-prod.yaml
│   ├── 31-app-splunk-dev.yaml
│   ├── 32-app-splunk-test.yaml
│   ├── 40-cheat-prod-to-dev.yaml
│   └── 41-cheat-prod-service-wrong-port.yaml
│
├── homework-results/
│   ├── outputs.txt
│   └── resources.json
│
├── manifests/
│   └── splunk/
│       ├── base/
│       │   ├── deployment.yaml
│       │   ├── kustomization.yaml
│       │   └── service.yaml
│       └── overlays/
│           ├── dev/
│           │   ├── deployment.yaml
│           │   └── kustomization.yaml
│           ├── prod/
│           │   ├── deployment.yaml
│           │   └── kustomization.yaml
│           └── test/
│               ├── deployment.yaml
│               └── kustomization.yaml
│
├── Screenshots/
|   ├── apply-policies-pt1.jpg
|   ├── apply-policies-pt2.jpg
|   ├── argocd-apps-list.jpg
|   ├── argocd-apps-sync.jpg
|   ├── build-infra-pt1.jpg
|   ├── build-infra-pt2.jpg
|   ├── build-infra-pt3.jpg
|   ├── build-infra-pt4.jpg
|   ├── build-infra-pt5.jpg
|   ├── collect-homework-pt1.jpg
|   ├── collect-homework-pt2.jpg
|   ├── deploy-apps.jpg
|   ├── install-gatekeeper.jpg
|   ├── prerequisites-script.jpg
|   ├── run-tests.jpg
|   ├── splunk-dev-tree.jpg
|   ├── splunk-prod-tree.jpg
|   ├── splunk-test-tree.jpg
|   ├── teardown-pt1.jpg
|   ├── teardown-pt2.jpg
|   ├── teardown-pt3.jpg
|   └── teardown-pt4.jpg
|
├── scripts/
│   ├── 0-prerequisites.sh
│   ├── 1-build-infrastructure.sh
│   ├── 2-install-gatekeeper.sh
│   ├── 3-apply-policies.sh
│   ├── 4-deploy-apps.sh
│   ├── 5-run-tests.sh
│   ├── 6-collect-homework.sh
│   └── 7-teardown.sh
│
├── .gitignore
├── 0-var.tf
├── 1-auth.tf
├── 2-vpc.tf
├── 3-subnets.tf
├── 4-igw.tf
├── 5-nat.tf
├── 6-rtb.tf
├── 7-eks.tf
├── 8-node.tf
├── 9-runtime.tf
├── 10-iam-oidc.tf
├── 11a-storage-iam.tf
├── 11b-storage-helm.tf
├── 12-outputs.tf
└── README.md
```

---

## 🧾 **Automation Scripts**

> !NOTE
> The lab is fully automated using Bash scripts.

---

### 0️⃣ **Preflight Checks**

```bash
./scripts/0-prerequisites.sh
```

![prerequisites-script.jpg](/Screenshots/prerequisites-script.jpg)

Validates:

* required CLI tools
* AWS authentication
* Terraform files
* Kubernetes access

---

### 1️⃣ **Build Infrastructure**

```bash
./scripts/1-build-infrastructure.sh
```

![build-infra-pt1.jpg](/Screenshots/build-infra-pt1.jpg)
![build-infra-pt2.jpg](/Screenshots/build-infra-pt2.jpg)
![build-infra-pt3.jpg](/Screenshots/build-infra-pt3.jpg)
![build-infra-pt4.jpg](/Screenshots/build-infra-pt4.jpg)
![build-infra-pt5.jpg](/Screenshots/build-infra-pt5.jpg)

Creates:

* VPC
* EKS cluster
* node groups
* IAM roles

---

### 2️⃣ **Install Gatekeeper**

```bash
./scripts/2-install-gatekeeper.sh
```

![install-gatekeeper.jpg](/Screenshots/install-gatekeeper.jpg)

Installs:

* Gatekeeper controller
* audit pods
* admission webhooks

---

### 3️⃣ **Apply Security Policies**

```bash
./scripts/3-apply-policies.sh
```

![apply-policies-pt1.jpg](/Screenshots/apply-policies-pt1.jpg)
![apply-policies-pt2.jpg](/Screenshots/apply-policies-pt2.jpg)

Deploys:

* namespaces
* constraint templates
* policy constraints

---

### 4️⃣ **Deploy Applications**

#### **Creates Argo CD namespace and installs Argo CD controller before validating prerequisites.**

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

![deploy-apps-pt1.jpg](/Screenshots/deploy-apps-pt1.jpg)

#### **Run Deployment Script**

```bash
./scripts/4-deploy-apps.sh
```

![deploy-apps-pt2.jpg](/Screenshots/deploy-apps-pt2.jpg)

Deploys Splunk apps through **Argo CD GitOps**.

---

### 5️⃣ **Run Security Tests**

```bash
./scripts/5-run-tests.sh
```

![run-tests.jpg](/Screenshots/run-tests.jpg)

Runs negative tests to ensure policies block invalid deployments.

---

### 6️⃣ **Collect Evidence**

```bash
./scripts/6-collect-homework.sh
```

![collect-homework-pt1.jpg](/Screenshots/collect-homework-pt1.jpg)
![collect-homework-pt2.jpg](/Screenshots/collect-homework-pt2.jpg)

Generates:

* [**Lab Verification Output**](/homework-results/outputs.txt)
* [**Cluster Resource Inventory**](/homework-results/resources.json)

---

### 7️⃣ **Teardown**

```bash
./scripts/7-teardown.sh
```

Removes:

* Argo CD apps
* Gatekeeper policies
* namespaces
* cluster resources

Then destroy infrastructure:

```bash
terraform destroy
```

![teardown-pt1.jpg](/Screenshots/teardown-pt1.jpg)
![teardown-pt2.jpg](/Screenshots/teardown-pt2.jpg)
![teardown-pt3.jpg](/Screenshots/teardown-pt3.jpg)
![teardown-pt4.jpg](/Screenshots/teardown-pt4.jpg)

---

## 🖼️ **Demo and Artifacts**

### 📦 **Argo CD Deployment Demo**

  <https://github.com/user-attachments/assets/d78d39d5-a6e8-4c16-ac43-8b3c0747ca07>

### 🖥️ **Splunk Apps Synchronized**

* ![argocd-apps-sync.jpg](/Screenshots/argocd-apps-sync.jpg)
* ![argocd-apps-list.jpg](/Screenshots/argocd-apps-list.jpg)

---

### 🌳 **Application Trees**

* **splunk-dev**
  ![splunk-dev-tree.jpg](/Screenshots/splunk-dev-tree.jpg)

* **splunk-prod**
  ![splunk-prod-tree.jpg](/Screenshots/splunk-prod-tree.jpg)

* **splunk-test**
  ![splunk-test-tree.jpg](/Screenshots/splunk-test-tree.jpg)

---

## 🧪 **Security Validation**

Two attack scenarios are tested.

### 1️⃣ **Test 1 – Namespace Violation**

Attempt to deploy prod app to dev namespace.

![namespace-violation.jpg](/Screenshots/namespace-violation.jpg)

Result:

```text
DENY: ArgoCD Application env=prod must deploy only to namespace splunk-prod
```

---

### 2️⃣ **Test 2 – Invalid Service Port**

Attempt to expose incorrect port.

![wrong-port.jpg](/Screenshots/wrong-port.jpg)

Result:

```text
DENY: Service splunk in namespace splunk-prod must expose port 8091
```

---

## 🧰 **Troubleshooting**

### 1️⃣ **Gatekeeper ConstraintTemplate Error**

Error:

```text
invalid ConstraintTemplate
```

Fix:

```bash
kubectl delete constrainttemplate k8sargoappenvironment
kubectl apply -f template.yaml
kubectl wait --for=condition=Established crd/k8sargoappenvironment.constraints.gatekeeper.sh
```

---

## 2️⃣ **Argo CD Application CRD Missing**

Error:

```text
no matches for kind Application
```

Fix:

```bash
kubectl apply -n argocd -f \
https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

---

## 3️⃣ **Argo CD Applications Stuck in Unknown**

Cause:

Missing AppProject or incorrect spec.

Fix:

```bash
kubectl -n argocd get applications
argocd app sync splunk-dev splunk-prod splunk-test
```

---

## 📊 **Lab Outcome**

After completing this lab the environment contains:

* AWS EKS cluster
* Argo CD GitOps controller
* OPA Gatekeeper admission controller
* policy enforcement for Kubernetes resources
* automated security validation scripts

This demonstrates **enterprise-grade Kubernetes runtime security.**

---

## 📚 **References**

* [**OPA Gatekeeper**](https://open-policy-agent.github.io/gatekeeper/)
* [**Kubernetes Admission Controllers**](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)
* [**Argo CD**](https://argo-cd.readthedocs.io)
* [**Terraform**](https://developer.hashicorp.com/terraform)
* [**AWS EKS**](https://docs.aws.amazon.com/eks/)

---

## 👥 **Authors**

* **Author:** *T.I.Q.S. DevSecOps*
* **Lab Team Lead:** *John Sweeney*
* [**GitHub Profile**](https://github.com/tiqsclass6)
