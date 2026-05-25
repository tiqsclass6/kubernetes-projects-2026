# 📽 **Project 3 – OPA Gatekeeper + Argo CD (Kubernetes Policy Enforcement)**

![AWS](https://img.shields.io/badge/AWS-Cloud-232F3E?style=for-the-badge&logo=amazonaws&logoColor=white)
![Amazon EKS](https://img.shields.io/badge/Amazon_EKS-Kubernetes-FF9900?style=for-the-badge&logo=amazoneks&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Argo CD](https://img.shields.io/badge/Argo_CD-GitOps-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![OPA Gatekeeper](https://img.shields.io/badge/OPA_Gatekeeper-Policy_Enforcement-7B42BC?style=for-the-badge&logo=openpolicyagent&logoColor=white)
![Admission Control](https://img.shields.io/badge/Security-Admission_Control-2E7D32?style=for-the-badge&logo=securityscorecard&logoColor=white)
![Rego](https://img.shields.io/badge/Rego-Policy_Language-00AEEF?style=for-the-badge&logo=openpolicyagent&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Splunk](https://img.shields.io/badge/Splunk-Observability-000000?style=for-the-badge&logo=splunk&logoColor=white)
![Automation](https://img.shields.io/badge/Testing-Automated_Scripts-F9A825?style=for-the-badge&logo=gnubash&logoColor=white)
![DevSecOps](https://img.shields.io/badge/Practice-DevSecOps-C62828?style=for-the-badge&logo=devdotto&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Repository-181717?style=for-the-badge&logo=github&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-0A66C2?style=for-the-badge)

---

## 🧪 **Project Overview**

This project demonstrates **OPA Gatekeeper (Kubernetes Policy Enforcement) integrated with a GitOps workflow using Argo CD.** The project simulates a **secure multi-environment platform** where applications are deployed through GitOps while **admission policies enforce strict environment rules.**

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

## 🏗 **Network Architecture Diagram**

![diagram.png](/images/diagram.png)

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

This project demonstrates real enterprise platform skills:

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
> The project is fully automated using Bash scripts.

---

### 0️⃣ [**Preflight Checks**](./scripts/0-prerequisites.sh)

```bash
./scripts/0-prerequisites.sh
```

![prerequisites-script.jpg](/images/prerequisites-script.jpg)

Validates:

* required CLI tools
* AWS authentication
* Terraform files
* Kubernetes access

---

### 1️⃣ [**Build Infrastructure**](./scripts/1-build-infrastructure.sh)

```bash
./scripts/1-build-infrastructure.sh
```

![build-infra-pt1.jpg](/images/build-infra-pt1.jpg)
![build-infra-pt2.jpg](/images/build-infra-pt2.jpg)
![build-infra-pt3.jpg](/images/build-infra-pt3.jpg)
![build-infra-pt4.jpg](/images/build-infra-pt4.jpg)
![build-infra-pt5.jpg](/images/build-infra-pt5.jpg)

Creates:

* VPC
* EKS cluster
* node groups
* IAM roles

---

### 2️⃣ [**Install Gatekeeper**](./scripts/2-install-gatekeeper.sh)

```bash
./scripts/2-install-gatekeeper.sh
```

![install-gatekeeper.jpg](/images/install-gatekeeper.jpg)

Installs:

* Gatekeeper controller
* audit pods
* admission webhooks

---

### 3️⃣ [**Apply Security Policies**](./scripts/3-apply-policies.sh)

```bash
./scripts/3-apply-policies.sh
```

![apply-policies-pt1.jpg](/images/apply-policies-pt1.jpg)
![apply-policies-pt2.jpg](/images/apply-policies-pt2.jpg)

Deploys:

* namespaces
* constraint templates
* policy constraints

---

### 4️⃣ [**Deploy Applications**](./scripts/4-deploy-apps.sh)

#### **Creates Argo CD namespace and installs Argo CD controller before validating prerequisites.**

```bash
kubectl create namespace argocd

kubectl apply -n argocd \
  --server-side \
  --force-conflicts \
  -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

![deploy-apps-pt1.jpg](/images/deploy-apps-pt1.jpg)

#### **Run Deployment Script**

```bash
./scripts/4-deploy-apps.sh
```

![deploy-apps-pt2.jpg](/images/deploy-apps-pt2.jpg)

Deploys Splunk apps through **Argo CD GitOps**.

---

### 5️⃣ [**Run Security Tests**](./scripts/5-run-tests.sh)

```bash
./scripts/5-run-tests.sh
```

![run-tests.jpg](/images/run-tests.jpg)

Runs negative tests to ensure policies block invalid deployments.

---

### 6️⃣ [**Collect Evidence**](./scripts/6-collect-homework.sh)

```bash
./scripts/6-collect-homework.sh
```

![collect-homework-pt1.jpg](/images/collect-homework-pt1.jpg)
![collect-homework-pt2.jpg](/images/collect-homework-pt2.jpg)

Generates:

* [**Project Verification Output**](/homework-results/outputs.txt)
* [**Cluster Resource Inventory**](/homework-results/resources.json)

---

### 7️⃣ [**Teardown**](./scripts/7-teardown.sh)

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

![teardown-pt1.jpg](/images/teardown-pt1.jpg)
![teardown-pt2.jpg](/images/teardown-pt2.jpg)
![teardown-pt3.jpg](/images/teardown-pt3.jpg)
![teardown-pt4.jpg](/images/teardown-pt4.jpg)

---

## 🖼️ **Demo and Artifacts**

### 📦 **Argo CD Deployment Demo**

  <https://github.com/user-attachments/assets/d78d39d5-a6e8-4c16-ac43-8b3c0747ca07>

### 🖥️ **Splunk Apps Synchronized**

* ![argocd-apps-sync.jpg](/images/argocd-apps-sync.jpg)
* ![argocd-apps-list.jpg](/images/argocd-apps-list.jpg)

---

### 🌳 **Application Trees**

* **splunk-dev**
  ![splunk-dev-tree.jpg](/images/splunk-dev-tree.jpg)

* **splunk-prod**
  ![splunk-prod-tree.jpg](/images/splunk-prod-tree.jpg)

* **splunk-test**
  ![splunk-test-tree.jpg](/images/splunk-test-tree.jpg)

---

## 🧪 **Security Validation**

Two attack scenarios are tested.

### 1️⃣ **Test 1 – Namespace Violation**

Attempt to deploy prod app to dev namespace.

![namespace-violation.jpg](/images/namespace-violation.jpg)

Result:

```text
DENY: ArgoCD Application env=prod must deploy only to namespace splunk-prod
```

---

### 2️⃣ **Test 2 – Invalid Service Port**

Attempt to expose incorrect port.

![wrong-port.jpg](/images/wrong-port.jpg)

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

## 📊 **Project Outcome**

After completing this project the environment contains:

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
* **Team Lead:** *John Sweeney*
* [**GitHub Profile**](https://github.com/tiqsclass6)
