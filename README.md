# 🧠 **Project 6 – Kong Ingress + API Key Authentication and Rate Limiting**

![AWS](https://img.shields.io/badge/Platform-Amazon%20EKS-FF9900?style=for-the-badge&logo=amazoneks&logoColor=white)
![Terraform](https://img.shields.io/badge/IaC-Terraform%201.10%2B-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-EKS-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Kong](https://img.shields.io/badge/API%20Gateway-Kong-003459?style=for-the-badge&logo=kong&logoColor=white)
![Helm](https://img.shields.io/badge/Package%20Manager-Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![Key Auth](https://img.shields.io/badge/Auth-Key--Auth-success?style=for-the-badge&logo=kong&logoColor=white)
![Rate Limiting](https://img.shields.io/badge/Traffic%20Control-Rate%20Limiting-blueviolet?style=for-the-badge)
![Kong Ingress](https://img.shields.io/badge/Ingress-Kong%20Ingress%20Controller-orange?style=for-the-badge)
![Validated](https://img.shields.io/badge/Status-Validated-brightgreen?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)

---

## 📌 **Table of Contents**

- [📖 **Project Overview**](#-project-overview)
- [🎯 **Project Objectives**](#-project-objectives)
- [✅ **Project Requirements**](#-project-requirements)
- [🏗️ **Network Architecture Summary**](#️-network-architecture-summary)
- [📁 **Project Structure**](#-project-structure)
- [🚀 **Deployment Steps**](#-deployment-steps)
- [🔑 **Manual Testing Commands**](#-manual-testing-commands)
- [✅ **Validation Results**](#-validation-results)
- [📸 **Artifacts and Screenshots**](#-artifacts-and-screenshots)
- [📊 **Useful Commands**](#-useful-commands)
- [🧹 **Teardown and Cost Control**](#-teardown-and-cost-control)
- [🛠️ **Troubleshooting**](#️-troubleshooting)
- [🧠 **Lessons Learned**](#-lessons-learned)
- [📚 **References**](#-references)
- [✍️ **Author**](#️-author)

---

## 📖 **Project Overview**

This project deploys **Kong Ingress Controller** on **Amazon Elastic Kubernetes Service (EKS)** using **Terraform**, **Helm**, and Kubernetes manifests. The lab demonstrates how to expose a sample NGINX application through Kong and secure it using **API key authentication** with the modern Kubernetes-native **Secret + KongConsumer** pattern.

The project also implements **rate limiting** to control repeated requests against a dedicated route. The completed deployment validates:

- Kubernetes ingress routing through Kong
- API key authentication using Kong `key-auth`
- Rate limiting using Kong `rate-limiting`
- AWS LoadBalancer exposure through the Kong proxy service
- Terraform-managed EKS infrastructure
- Repeatable deployment and teardown automation through Bash scripts

---

## 🎯 **Project Objectives**

| **Objective**                       | **Description**                                                                            |
| ----------------------------------- | ------------------------------------------------------------------------------------------ |
| **Provision EKS Infrastructure**    | Use Terraform to build AWS networking, EKS, node group, IAM, OIDC, and platform resources. |
| **Install Kong Ingress Controller** | Use Helm through Terraform to install Kong into the EKS cluster.                           |
| **Deploy a Test Application**       | Deploy an NGINX-based `hello-app` service in Kubernetes.                                   |
| **Expose Application Through Kong** | Route `/hello` and `/hello-ratelimit` through Kong Ingress.                                |
| **Enforce API Key Authentication**  | Protect `/hello` with Kong `key-auth`.                                                     |
| **Enforce Rate Limiting**           | Protect `/hello-ratelimit` with Kong `rate-limiting`.                                      |
| **Validate Access Behavior**        | Confirm expected `401`, `200`, and `429` responses.                                        |
| **Clean Up Safely**                 | Remove Kubernetes resources before manually running `terraform destroy`.                   |

---

## ✅ **Project Requirements**

| **Requirement**        | **Purpose**                                                           |
| ---------------------- | --------------------------------------------------------------------- |
| **AWS Account**        | Hosts EKS, LoadBalancer, VPC, IAM, NAT Gateway, and worker nodes.     |
| **AWS CLI**            | Authenticates to AWS and updates kubeconfig for EKS access.           |
| **Terraform 1.10+**    | Provisions infrastructure as code.                                    |
| **kubectl**            | Applies and validates Kubernetes resources.                           |
| **Helm 3.x**           | Installs Kong Ingress Controller through the Terraform Helm provider. |
| **Git**                | Stores and submits the repository.                                    |
| **Bash / Git Bash**    | Runs `deploy.sh` and `teardown.sh`.                                   |
| **Visual Studio Code** | Edits Terraform, YAML, Bash, and Markdown files.                      |

### Recommended CLI Checks

```bash
# Check versions of required CLI tools
aws --version
terraform version
kubectl version --client
helm version
git --version
```

![version-commands.jpg](images/version-commands.jpg)

---

## 🏗️ **Network Architecture Summary**

```mermaid
flowchart TD
    %% =========================
    %% EXTERNAL CLIENT LAYER
    %% =========================
    U["User / Client<br/>Browser, curl, API consumer"]

    %% =========================
    %% AWS LAYER
    %% =========================
    subgraph AWS["AWS"]
        ALB["AWS LoadBalancer<br/>(External ELB/NLB provisioned from Kubernetes Service type=LoadBalancer)"]
    end

    U -->|"HTTP/HTTPS Request"| ALB

    %% =========================
    %% EKS / KUBERNETES CLUSTER
    %% =========================
    subgraph EKS["Amazon EKS / Kubernetes Cluster"]
        
        %% -------------------------
        %% Kong Namespace
        %% -------------------------
        subgraph KONGNS["Namespace: kong"]
            KONGPROXY["Kong Gateway Proxy Service<br/>Service: kong-gateway-proxy<br/>Type: LoadBalancer"]
            KIC["Kong Ingress Controller<br/>Watches Ingress, Services,<br/>KongPlugin, KongConsumer resources"]
        end

        %% -------------------------
        %% Application Namespace
        %% -------------------------
        subgraph CHEWNS["Namespace: chewbacca"]

            %% Ingress resources
            HELLOING["Ingress: hello-ingress<br/>Path: /hello<br/>Ingress Class: kong<br/>Annotations:<br/>- konghq.com/plugins: key-auth-plugin,my-rate-limiting-plugin<br/>- konghq.com/strip-path: true"]

            RATELIMITING["Ingress: hello-ratelimit-ingress<br/>Path: /hello-ratelimit<br/>Ingress Class: kong<br/>Annotations:<br/>- konghq.com/plugins: my-rate-limiting-plugin<br/>- konghq.com/strip-path: true"]

            %% Plugin resources
            KEYAUTH["KongPlugin: key-auth-plugin<br/>Plugin: key-auth"]
            RATELIMIT["KongPlugin: my-rate-limiting-plugin<br/>Plugin: rate-limiting<br/>Config: minute=5, policy=local"]

            %% Consumer / credential resources
            CONSUMER["KongConsumer: chewbacca<br/>username: chewbacca"]
            APIKEY["Secret / Credential: chewbacca-key<br/>API key used by client"]

            %% Application service + deployment
            SVC["Service: hello-service<br/>Type: ClusterIP<br/>Port: 80<br/>Selects app=hello"]
            DEPLOY["Deployment: hello-app<br/>Replicas: 2"]

            %% Supporting config
            CM["ConfigMap: chewbacca-html<br/>Supplies custom HTML content"]

            %% Pods
            POD1["NGINX Pod 1<br/>Container: nginx"]
            POD2["NGINX Pod 2<br/>Container: nginx"]
        end
    end

    %% =========================
    %% TRAFFIC FLOW
    %% =========================
    ALB -->|"Forwards traffic to Kubernetes"| KONGPROXY
    KONGPROXY -->|"Handled by Kong data plane"| KIC

    %% Route selection
    KIC -->|"Matches request path /hello"| HELLOING
    KIC -->|"Matches request path /hello-ratelimit"| RATELIMITING

    %% Plugin binding
    HELLOING --> KEYAUTH
    HELLOING --> RATELIMIT
    RATELIMITING --> RATELIMIT

    %% Consumer / credential association
    KEYAUTH -->|"Validates API key against"| CONSUMER
    CONSUMER -->|"Uses credential"| APIKEY

    %% Backend service routing
    HELLOING -->|"Route to backend"| SVC
    RATELIMITING -->|"Route to backend"| SVC

    %% Service to deployment
    SVC -->|"Load-balances to matching pods"| DEPLOY

    %% Deployment internals
    CM -->|"Mounted/consumed by"| DEPLOY
    DEPLOY --> POD1
    DEPLOY --> POD2

    %% =========================
    %% REQUEST BEHAVIOR NOTES
    %% =========================
    HELLONOTE["/hello behavior<br/>- Requires valid apikey header<br/>- Also rate-limited<br/>- Returns backend content if authorized"]

    RLNOTE["/hello-ratelimit behavior<br/>- No API key required<br/>- Rate-limited only<br/>- Returns 429 after threshold exceeded"]

    HELLOING -.-> HELLONOTE
    RATELIMITING -.-> RLNOTE
```

### Resource Flow

1. Terraform provisions the AWS VPC, subnets, route tables, NAT gateway, EKS cluster, and managed node group.
2. Terraform configures IAM/OIDC support for Kubernetes service accounts.
3. Terraform installs Kong Ingress Controller through Helm.
4. Terraform deploys the sample NGINX application and service.
5. The deployment script applies Kong plugins, consumer, API key secret, and ingress routes.
6. Kong exposes the app through an AWS LoadBalancer service.
7. Validation confirms key-auth and rate-limiting behavior.

---

## 📁 **Project Structure**

```text
project-6/
├── images/
│   ├── deliverables-pt1.jpg
│   ├── deliverables-pt2.jpg
│   ├── deploy-pt1.jpg
│   ├── deploy-pt2.jpg
│   ├── deploy-pt3.jpg
│   ├── teardown-pt1.jpg
│   ├── teardown-pt2.jpg
│   ├── terraform-apply.jpg
│   ├── terraform-destroy-pt1.jpg
│   ├── terraform-destroy-pt2.jpg
│   ├── terraform-init-fmt-validate.jpg
│   ├── terraform-plan.jpg
│   └── version-commands.jpg 
│
├── manifests/
│   ├── apply_key_ingress.yaml
│   ├── apply_ratelimit_ingress.yaml
│   ├── chewbacca_key.yaml
│   ├── chewbacca.yaml
│   ├── kong_plugin_api.yaml
│   └── kong_plugin_ratelimit.yaml
│
├── scripts/
│   ├── deploy.sh
│   └── teardown.sh
│
├── terraform/
│   ├── .gitignore
│   ├── .terraform.lock.hcl
│   ├── 0-var.tf
│   ├── 1-auth.tf
│   ├── 2-vpc.tf
│   ├── 3-subnets.tf
│   ├── 4-igw.tf
│   ├── 5-nat.tf
│   ├── 6-rtb.tf
│   ├── 7-eks.tf
│   ├── 8-node.tf
│   ├── 9-runtime.tf
│   ├── 10-iam-oidc.tf
│   ├── 11a-storage-iam.tf
│   ├── 11b-storage-helm.tf
│   ├── 12-kong.tf
│   └── 13-output.tf
│
└── README.md
```

> The local `.terraform/` directory is intentionally excluded because it is generated by `terraform init` and should not be committed.

---

## 🚀 **Deployment Steps**

### **1. Open the Project**

```bash
cd project-6
```

### **2. Provision Infrastructure with Terraform**

```bash
cd terraform
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

![terraform-init-fmt-validate.jpg](images/terraform-init-fmt-validate.jpg)
![terraform-plan.jpg](images/terraform-plan.jpg)
![terraform-apply.jpg](images/terraform-apply.jpg)

### **3. Return to the Project Root**

```bash
cd ..
```

### **4. Deploy and Validate Kong Resources**

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

![deploy-pt1.jpg](images/deploy-pt1.jpg)
![deploy-pt2.jpg](images/deploy-pt2.jpg)
![deploy-pt3.jpg](images/deploy-pt3.jpg)

The deployment script:

- Validates cluster access and Kong CRDs
- Applies KongPlugin resources
- Applies the API key Secret
- Applies the KongConsumer
- Applies Ingress routes
- Detects the Kong LoadBalancer endpoint
- Tests authentication and rate limiting

---

## 🔑 **Manual Testing Commands**

### **Get the Kong LoadBalancer hostname:**

```bash
export KONG_HOST=$(kubectl get svc -n kong kong-gateway-proxy \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "$KONG_HOST"
```

### **Test `/hello` without authentication. Expected result: `401 Unauthorized`.**

```bash
curl -i http://<KONG_HOST>/hello
```

### **Test `/hello` with a valid API key. Expected result: `200 OK`.**

```bash
curl -i http://<KONG_HOST>/hello -H "apikey: super-secret-key"
```

### **Test the rate-limited endpoint. Expected initial result: `200 OK`.**

```bash
curl -i http://<KONG_HOST>/hello-ratelimit
```

### **Trigger the rate limit. Expected result: `429 Too Many Requests` after repeated requests.**

```bash
for i in {1..10}; do
  curl -i http://<KONG_HOST>/hello-ratelimit
done
```

---

## ✅ **Validation Results**

| **Test**                              | **Expected Result**     | **Actual Result**    | **Status** |
| ------------------------------------- | ----------------------- | -------------------- | ---------- |
| `/hello` without API key              | `401 Unauthorized`      | `401`                | ✅ PASS    |
| `/hello` with valid API key           | `200 OK`                | `200`                | ✅ PASS    |
| `/hello-ratelimit` initial request    | `200 OK`                | `200`                | ✅ PASS    |
| Rate limiting after repeated requests | `429 Too Many Requests` | `429` on 5th request | ✅ PASS    |

### Example Kong Endpoint

```text
http://aa5e03fe7d1034f9eb4d2347703964f2-1968007985.us-east-1.elb.amazonaws.com
```

---

## 📸 **Artifacts and Screenshots**

> Replace placeholder screenshot paths with actual screenshots before final submission.

| **Artifact**         | **Description**                                      | **Screenshot**                                     |
| -------------------- | ---------------------------------------------------- | -------------------------------------------------- |
| **401/200**          | `/hello` request **without and with** valid API key. | ![`deliverables-pt1`](images/deliverables-pt1.jpg) |
| **Kong External IP** | `/hello` request with valid API key.                 | ![`deliverables-pt2`](images/deliverables-pt2.jpg) |

---

## 📊 **Useful Commands**

```bash
# View Kong resources
kubectl get kongplugin -n chewbacca
kubectl get kongconsumer

# View API key Secret
kubectl get secret chewbacca-key

# View Ingress and services
kubectl get ingress
kubectl get svc -n kong

# Describe protected Ingress resources
kubectl describe ingress hello-ingress
kubectl describe ingress hello-ratelimit-ingress

# View Kong pods, services, and deployments
kubectl get pods -n kong
kubectl get deploy hello-app
kubectl get svc hello-service

# View hello-app pods
kubectl get pods -l app=hello-app

# View logs for hello-app pods
kubectl logs -l app=hello-app
```

---

## 🧹 **Teardown and Cost Control**

Run the Kubernetes teardown script before destroying Terraform-managed infrastructure. This helps remove Kubernetes LoadBalancer resources first, reducing the chance of AWS dependency errors during teardown.

### 1. Run Kubernetes Teardown

From the `project-6` root directory:

```bash
chmod +x scripts/teardown.sh
./scripts/teardown.sh
```

![teardown-pt1.jpg](images/teardown-pt1.jpg)
![teardown-pt2.jpg](images/teardown-pt2.jpg)

### 2. Destroy Terraform Infrastructure

```bash
cd terraform
terraform destroy
```

![terraform-destroy-pt1.jpg](images/terraform-destroy-pt1.jpg)
![terraform-destroy-pt2.jpg](images/terraform-destroy-pt2.jpg)

### Cost-Saving Note

EKS clusters, EC2 worker nodes, NAT gateways, and AWS LoadBalancers can generate charges while running. Always run the teardown and Terraform destroy steps after the lab is complete.

---

## 🛠️ **Troubleshooting**

| **Issue**                                         | **Cause**                                                             | **Resolution**                                                                                                    |
| ------------------------------------------------- | --------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `KongCredential` CRD not found                    | Older Kong credential method was used.                                | Use a Kubernetes Secret labeled `konghq.com/credential: key-auth` and reference it in `KongConsumer.credentials`. |
| `401 Unauthorized` with valid key                 | Consumer was not linked to the credential Secret.                     | Confirm `credentials: - chewbacca-key` exists in `chewbacca.yaml`.                                                |
| Backend returns `404 Not Found`                   | Kong forwarded `/hello` or `/hello-ratelimit` directly to NGINX.      | Add `konghq.com/strip-path: "true"` to the Ingress annotations.                                                   |
| LoadBalancer is pending                           | AWS is still provisioning the ELB/NLB.                                | Wait a few minutes and rerun `kubectl get svc -n kong`.                                                           |
| Plugin not attached                               | Ingress annotation is missing or misspelled.                          | Verify `konghq.com/plugins` annotation on the Ingress.                                                            |
| Rate limit does not trigger                       | Counter window reset or not enough requests were sent.                |  Run the loop test with 10 or more requests.                                                                      |
| Terraform destroy fails with dependency errors    | LoadBalancer, ENI, or security group resources may still be deleting. | Wait several minutes, verify Kubernetes services are removed, then rerun `terraform destroy`.                     |

### **Troubleshooting Commands**

```bash
# View Kong resources
kubectl get crd | grep kong
kubectl get kongplugin
kubectl get kongconsumer

# View API key Secret
kubectl get secret chewbacca-key -o yaml

# View Ingress and services
kubectl describe ingress hello-ingress
kubectl describe ingress hello-ratelimit-ingress

# View Kong pods, services, and deployments
kubectl get svc -n kong
kubectl get pods -n kong

# View logs for Kong controller
kubectl logs -n kong deploy/kong-controller
```

---

## 🧠 **Lessons Learned**

### **What I Learned**

This project reinforced how Kubernetes Ingress, API gateways, and cloud load balancers work together. Kong acts as the API gateway layer, while AWS provides the external LoadBalancer and EKS provides the Kubernetes control plane and worker nodes.

### **Customer/User Value**

For a customer or junior cloud engineer, this lab demonstrates a repeatable way to expose services securely through an API gateway. Instead of exposing backend services directly, Kong provides a centralized control point for authentication, rate limiting, and traffic routing.

### **Challenges Encountered**

Key challenges included:

- Replacing the older `KongCredential` approach with the modern Secret-based credential pattern
- Ensuring `KongConsumer` correctly referenced the API key Secret
- Fixing backend `404` responses by adding `konghq.com/strip-path: "true"`
- Ensuring the deployment script could locate manifests from the project root
- Cleaning Kubernetes LoadBalancer resources before Terraform destroy

### **Cost Control**

The teardown workflow helps reduce AWS costs by removing Kubernetes LoadBalancer resources before destroying Terraform infrastructure. This is important because EKS clusters, NAT gateways, EC2 nodes, and LoadBalancers may continue billing if they are left running.

---

## 📚 **References**

- [**Amazon EKS documentation**](https://docs.aws.amazon.com/eks/)
- [**Terraform documentation**](https://developer.hashicorp.com/terraform/docs)
- [**Helm documentation**](https://helm.sh/docs/)
- [**Kong Ingress Controller documentation**](https://developer.konghq.com/kubernetes-ingress-controller/)
- [**Kubernetes documentation**](https://kubernetes.io/docs/)

---

## ✍️ **Author**

| **Role**         | **Name**                                   |
| ---------------- | ------------------------------------------ |
| **Author**       | `T.I.Q.S.`                                 |
| **Group Leader** | `John Sweeney`                             |
| **Group Name**   | `The Brotherhood of jerMutants - Wolfpack` |
| **Version**      | `1.0.0`                                    |
| **Date**         | `May 18, 2026`                             |
