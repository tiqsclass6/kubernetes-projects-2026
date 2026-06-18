# 🚀 **Project 7: Kong Rate Limiting + Key Auth on GKE**

![Terraform](https://img.shields.io/badge/Terraform-IaC-844FBA?style=for-the-badge&logo=terraform&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google_Cloud-Platform-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![GKE](https://img.shields.io/badge/GKE-Google_Kubernetes_Engine-4285F4?style=for-the-badge&logo=googlekubernetesengine&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Kong](https://img.shields.io/badge/Kong-API_Gateway-003459?style=for-the-badge&logo=kong&logoColor=white)
![Kong Ingress](https://img.shields.io/badge/Kong_Ingress-Controller-00A3A3?style=for-the-badge&logo=kong&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-Package_Manager-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![LoadBalancer](https://img.shields.io/badge/LoadBalancer-External_Traffic-1976D2?style=for-the-badge&logo=googlecloud&logoColor=white)
![Ingress](https://img.shields.io/badge/Ingress-L7_Routing-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Key Auth](https://img.shields.io/badge/Key_Auth-API_Security-FF6D00?style=for-the-badge&logo=securityscorecard&logoColor=white)
![Rate Limiting](https://img.shields.io/badge/Rate_Limiting-Abuse_Control-00C853?style=for-the-badge&logo=datadog&logoColor=white)
![API Security](https://img.shields.io/badge/API_Security-Gateway_Enforcement-D32F2F?style=for-the-badge&logo=owasp&logoColor=white)
![k6](https://img.shields.io/badge/k6-Load_Testing-7D64FF?style=for-the-badge&logo=k6&logoColor=white)
![curl](https://img.shields.io/badge/curl-HTTP_Testing-073551?style=for-the-badge&logo=curl&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-Automation-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![YAML](https://img.shields.io/badge/YAML-Manifests-CB171E?style=for-the-badge&logo=yaml&logoColor=white)
![ConfigMap](https://img.shields.io/badge/ConfigMap-App_Config-1565C0?style=for-the-badge&logo=kubernetes&logoColor=white)
![Secrets](https://img.shields.io/badge/Secrets-Credentials-6A1B9A?style=for-the-badge&logo=kubernetes&logoColor=white)
![Google Artifact Registry](https://img.shields.io/badge/Artifact_Registry-Container_Artifacts-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![Cloud NAT](https://img.shields.io/badge/Cloud_NAT-Egress_Access-34A853?style=for-the-badge&logo=googlecloud&logoColor=white)
![IAM](https://img.shields.io/badge/IAM-Access_Control-FBBC04?style=for-the-badge&logo=googlecloud&logoColor=black)
![Git](https://img.shields.io/badge/Git-Version_Control-F05032?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-Portfolio_Repo-181717?style=for-the-badge&logo=github&logoColor=white)
![Platform Engineering](https://img.shields.io/badge/Platform_Engineering-Gateway_Control-2E7D32?style=for-the-badge&logo=kubernetes&logoColor=white)

---

## 📌 **Project Overview**

This project demonstrates how to protect a Kubernetes-hosted web application from API abuse using **Kong Gateway** and the **Kong Ingress Controller** on **Google Kubernetes Engine (GKE)**. The infrastructure is provisioned with **Terraform**, the application is deployed with Kubernetes manifests, and Kong enforces gateway-level controls before traffic reaches the backend service.

The lab focuses on two major API protection controls:

* **Key Authentication** — blocks unauthenticated users before they reach the application.
* **Rate Limiting** — limits how many requests a client can send during a defined time window.

The completed implementation proves that Kong can act as a centralized API control plane for Kubernetes workloads. Requests without a valid API key return **401 Unauthorized**, valid requests return **200 OK**, and request floods return **429 Too Many Requests** after the configured threshold is exceeded.

---

## 🏗 **Network Architecture Diagram**

![diagram.png](/images/diagram.png)

### **Traffic Flow**

1. A client sends HTTP traffic to the Kong external LoadBalancer.
2. Kong evaluates the Ingress annotations and attached plugins.
3. The `key-auth` plugin checks for a valid API key.
4. The `rate-limiting` plugin enforces the request limit.
5. Allowed traffic is routed to the Kubernetes `hello-service`.
6. The service forwards traffic to the backend `hello` pods.
7. The backend serves the custom HTML page from the ConfigMap.

---

## 🎯 **Project Requirements**

The project implements the following Platform Engineering, Kubernetes, and API Gateway capabilities.

### **Infrastructure**

* Terraform-based provisioning of GCP infrastructure
* Google Kubernetes Engine cluster deployment
* VPC, subnet, firewall, NAT, and runtime configuration
* IAM/OIDC-related Terraform configuration
* Repeatable infrastructure build and destroy workflow

### **Kubernetes Application**

* Kubernetes Deployment for the backend web application
* Kubernetes Service for internal service discovery
* Kubernetes ConfigMap for the custom HTML page
* Kubernetes Ingress for routing external traffic through Kong
* Namespace-scoped deployment under `kong`

### **API Gateway Controls**

* Kong Gateway deployed into GKE
* Kong Ingress Controller reconciliation
* `KongPlugin` resource for key authentication
* `KongPlugin` resource for rate limiting
* `KongConsumer` resource for API consumer identity
* Kubernetes Secret for API key credential storage
* Ingress annotations for plugin attachment

### **Testing and Validation**

* `curl` testing for HTTP status verification
* k6 load testing for request flood simulation
* Authenticated and unauthenticated API tests
* Evidence collection for `401`, `200`, and `429` responses
* Kubernetes resource exports for proof of configuration

### **Automation Pipeline**

Script-driven project lifecycle with repeatable execution:

```text
terraform build → deploy kong/app → verify gateway → run tests → collect evidence → teardown
```

* `scripts/1-deploy.sh` deploys Kong, the app, plugins, consumer, and credential
* `scripts/2-verify.sh` validates deployed resources and endpoint behavior
* `scripts/3-teardown.sh` removes Kubernetes resources and supports cleanup
* `python/collect-deliverables.py` collects and organizes evidence artifacts

---

## 🧠 **Interview Talk Track (Business + DevOps)**

### **Business Perspective**

APIs are common targets for abuse because they are directly exposed to users, scripts, and automated clients. Even when an API requires authentication, a valid user or compromised key can still overload backend services with excessive requests. This can increase cloud costs, degrade user experience, or cause a denial-of-service condition.

This project demonstrates how an organization can reduce that risk by enforcing controls at the API gateway layer. Kong provides a centralized enforcement point where authentication and rate limiting can be applied consistently without requiring every backend application team to write custom security logic.

The business value is improved reliability, better abuse prevention, and a repeatable control pattern that can be applied across many services.

### **DevOps / Platform Engineering Perspective**

This project demonstrates a Kubernetes-native gateway control pattern using declarative infrastructure and declarative application configuration.

Key practices implemented include:

* Infrastructure provisioning with Terraform
* Gateway deployment on GKE
* Kubernetes-native API gateway configuration using Kong CRDs
* Declarative plugin attachment using Ingress annotations
* Secret-based API key credential handling
* k6-based load testing for proof of control
* Script-driven validation and evidence collection
* Clean teardown to avoid unnecessary cloud spend

From a platform perspective, the gateway becomes a reusable shared service. Application teams can deploy services behind Kong while the platform layer enforces authentication, rate limiting, and routing standards.

---

## 📂 **Project Structure**

```text
project-7/
├── deliverables/
│   ├── 01-yaml/
│   │   ├── ingress-annotation-evidence.md
│   │   ├── ingress-rate-limit-plugin.md
│   │   ├── key-auth-credential.md
│   │   ├── key-auth-plugin.md
│   │   ├── kong-consumer.md
│   │   ├── live-ingress-hello-ingress-export.md
│   │   ├── live-key-auth-plugin-export.md
│   │   ├── live-key-auth-secret-export-redacted.md
│   │   ├── live-kong-consumer-export.md
│   │   ├── live-rate-limit-plugin-export.md
│   │   └── rate-limit-plugin.md
│   │
│   ├── 02-evidence/
│   │   ├── 00-kong-endpoint.txt
│   │   ├── 01-kubectl-get-kongplugin.txt
│   │   ├── 02-kubectl-describe-ingress-hello-ingress.txt
│   │   ├── 03-kubectl-get-svc.txt
│   │   ├── 04-kubectl-get-pods.txt
│   │   ├── 05-kubectl-logs-kong-controller-pod.txt
│   │   ├── 06-k6-run-rate-test-unauthenticated.txt
│   │   ├── 07-k6-run-key-rate-test-authenticated.txt
│   │   ├── 08-401-no-api-key-evidence.txt
│   │   ├── 09-200-valid-api-key-evidence.txt
│   │   └── 10-429-authenticated-flood-evidence.txt
│   │
│   ├── 03-explanation/
│   │   └── short-explanation-and-reflection.md
│   │
│   └── README.md
│
├── images/
│   ├── cli-versions.jpg
│   ├── deliverables-script-pt1.jpg
│   ├── deliverables-script-pt2.jpg
│   ├── deploy-pt1.jpg
│   ├── deploy-pt2.jpg
│   ├── deploy-pt3.jpg
│   ├── deploy-pt4.jpg
│   ├── frontpage-with-auth-header.jpg
│   ├── gcloud-verification-cmds.jpg
│   ├── key-test-authentication.jpg
│   ├── kong-api-verification-and-deliverables.mp4
│   ├── kong-manual-cmds.jpg
│   ├── kubernetes-config.jpg
│   ├── rate-test-and-curl-commands.mp4
│   ├── rate-test-no-key.jpg
│   ├── rate-test-with-key.jpg
│   ├── teardown-manual.jpg
│   ├── teardown-pt1.jpg
│   ├── teardown-pt2.jpg
│   ├── teardown.mp4
│   ├── terraform-apply.jpg
│   ├── terraform-destroy.jpg
│   ├── terraform-init-fmt-validate.jpg
│   ├── terraform-plan.jpg
│   └── verify.jpg
│
├── manifests/
│   ├── hello-configmap.yaml
│   ├── hello-deployment.yaml
│   ├── hello-service.yaml
│   ├── ingress-rate-limit-plugin.yaml
│   ├── key-auth-credential.yaml
│   ├── key-auth-plugin.yaml
│   ├── kong-consumer.yaml
│   ├── nginx-config.yaml
│   └── rate-limit-plugin.yaml
│
├── python/
│   ├── collect-deliverables.py
│   ├── key-rate-test.js
│   ├── keyloop.sh
│   ├── rate-test.js
│   └── simpleloop.sh
│
├── scripts/
│   ├── 1-deploy.sh
│   ├── 2-verify.sh
│   └── 3-teardown.sh
│
├── terraform/
│   ├── 0-var.tf
│   ├── 1-auth.tf
│   ├── 2-vpc.tf
│   ├── 3-subnets.tf
│   ├── 4-firewall.tf
│   ├── 5-nat.tf
│   ├── 6-artifact-registry.tf
│   ├── 7-gke.tf
│   ├── 8-node.tf
│   ├── 9-runtime.tf
│   ├── 10-iam-oidc.tf
│   ├── 11-output.tf
│   └── terraform.tfvars
├── .gitignore
└── README.md
```

---

## ⚙️ **Deployment Steps**

### 0️⃣ **Prerequisites**

Before running the project, confirm the following tools are installed and authenticated:

```bash
terraform version
gcloud version
kubectl version --client
helm version
k6 version
git --version
```

![cli-versions.jpg](/images/cli-versions.jpg)

Authenticate to Google Cloud:

```bash
gcloud auth login
gcloud config set project class-6-5-tiqs
```

Verify the active project:

```bash
gcloud config get-value project
```

![gcloud-verification-cmds.jpg](/images/gcloud-verification-cmds.jpg)

---

### 1️⃣ **Build Infrastructure**

Initialize and validate Terraform:

```bash
cd terraform
terraform init
terraform fmt -recursive
terraform validate
```

![terraform-init-fmt-validate.jpg](/images/terraform-init-fmt-validate.jpg)

Generate a Terraform plan:

```bash
terraform plan
```

![terraform-plan.jpg](/images/terraform-plan.jpg)

Apply the Terraform configuration:

```bash
terraform apply
```

![terraform-apply.jpg](/images/terraform-apply.jpg)

Creates:

* GKE cluster
* VPC networking
* Subnets
* Firewall rules
* NAT configuration
* Artifact Registry
* Node pool
* Runtime/IAM/OIDC-related resources

---

### 2️⃣ **Configure Kubernetes Credentials**

Connect `kubectl` to the GKE cluster:

```bash
gcloud container clusters get-credentials kong \
  --zone us-central1-b \
  --project class-6-5-tiqs
```

Validate cluster access:

```bash
kubectl get nodes
kubectl get namespaces
```

![kubernetes-config.jpg](/images/kubernetes-config.jpg)

---

### 3️⃣ **Deploy Kong Gateway and the Application**

Run the deployment script:

```bash
chmod +x scripts/1-deploy.sh
./scripts/1-deploy.sh
```

![deploy-pt1.jpg](/images/deploy-pt1.jpg)
![deploy-pt2.jpg](/images/deploy-pt2.jpg)
![deploy-pt3.jpg](/images/deploy-pt3.jpg)
![deploy-pt4.jpg](/images/deploy-pt4.jpg)

This script deploys or applies:

* Kong Gateway / Kong Ingress Controller
* `hello` backend application
* `hello-service`
* `hello-configmap`
* Kong key-auth plugin
* Kong rate-limiting plugin
* Kong consumer
* API key credential
* Ingress annotations for gateway policy enforcement

> NOTE: The script will wait for 5 minutes to allow the user to update the `KONG_EXTERNAL_IP` into the files `python/rate-test.js` and `python/key-rate-test.js` before proceeding with script execution. User must press the `Enter` key after updating and saving the files to continue with the deployment.

---

### 4️⃣ **Verify Kong and Kubernetes Resources**

Run the verification script:

```bash
chmod +x scripts/2-verify.sh
./scripts/2-verify.sh
```

![verify.jpg](/images/verify.jpg)

Manual verification commands:

```bash
kubectl get svc -n kong
kubectl get pods -n kong
kubectl get kongplugin -n kong
kubectl get kongconsumer -n kong
kubectl describe ingress hello-ingress -n kong
kubectl logs -n kong -l app.kubernetes.io/name=ingress-controller
```

![kong-manual-cmds.jpg](/images/kong-manual-cmds.jpg)

---

### 5️⃣ **Test Key Authentication**

Send a request without an API key:

```bash
curl -i -k http://<KONG_PROXY_ENDPOINT>/
```

Expected unauthenticated result:

```text
HTTP/1.1 401 Unauthorized
No API key found in request
```

Send a request with a valid API key:

```bash
curl -i -k http://<KONG_PROXY_ENDPOINT>/ -H "apikey: <REDACTED_API_KEY>"
```

Expected authenticated result:

```text
HTTP/1.1 200 OK
```

![key-test-authentication.jpg](/images/key-test-authentication.jpg)

---

### 6️⃣ **Run Rate Limiting Tests**

Run unauthenticated load testing:

```bash
k6 run python/rate-test.js
```

![rate-test-no-key.jpg](/images/rate-test-no-key.jpg)

Run authenticated load testing:

```bash
k6 run python/key-rate-test.js
```

![rate-test-with-key.jpg](/images/rate-test-with-key.jpg)

Expected gateway behavior:

* Missing API key returns **401 Unauthorized**
* Valid API key returns **200 OK**
* Flood traffic eventually returns **429 Too Many Requests**

Expected rate limiting result:

```text
HTTP/1.1 429 Too Many Requests
```

Evidence:

```text
deliverables/02-evidence/06-k6-run-rate-test-unauthenticated.txt
deliverables/02-evidence/07-k6-run-key-rate-test-authenticated.txt
deliverables/02-evidence/10-429-authenticated-flood-evidence.txt
```

---

### 7️⃣ **Collect Deliverables**

Run the artifact collection script:

```bash
python python/collect-deliverables.py
```

![deliverables-script-pt1.jpg](/images/deliverables-script-pt1.jpg)
![deliverables-script-pt2.jpg](/images/deliverables-script-pt2.jpg)

The script organizes proof files into:

```text
deliverables/01-yaml/
deliverables/02-evidence/
deliverables/03-explanation/
```

---

## 🧪 **Project Demo**

### **What Students Learn**

This project teaches how to build and validate a gateway-based API protection pattern in Kubernetes.

Students learn how to:

* Provision GKE infrastructure with Terraform
* Deploy Kong Gateway into Kubernetes
* Attach Kong plugins to an Ingress
* Configure API key authentication
* Configure request rate limiting
* Validate gateway behavior with curl
* Run k6 load tests
* Capture evidence for engineering proof
* Tear down infrastructure to reduce cloud costs

Demo evidence:

* [**Kong API Verification and Deliverables Video**](/images/kong-api-verification-and-deliverables.mp4)
* [**Rate Test and curl Commands Video**](/images/rate-test-and-curl-commands.mp4)

---

## 📸 **Artifacts / Screenshots**

### **Front page of the application with API key header**

![frontpage-with-auth-header.jpg](/images/frontpage-with-auth-header.jpg)

### **Artifacts are generated and organized using:**

```python
python/collect-deliverables.py
```

![collect-artifacts-script.jpg](/images/deliverables-script-pt1.jpg)
![collect-artifacts-script-2.jpg](/images/deliverables-script-pt2.jpg)

### **YAML and Live Resource Evidence**

* [**Ingress Annotation Evidence**](/deliverables/01-yaml/ingress-annotation-evidence.md)
* [**Ingress Rate Limit Plugin YAML**](/deliverables/01-yaml/ingress-rate-limit-plugin.md)
* [**Key Auth Credential YAML**](/deliverables/01-yaml/key-auth-credential.md)
* [**Key Auth Plugin YAML**](/deliverables/01-yaml/key-auth-plugin.md)
* [**Kong Consumer YAML**](/deliverables/01-yaml/kong-consumer.md)
* [**Live Ingress Export**](/deliverables/01-yaml/live-ingress-hello-ingress-export.md)
* [**Live Key Auth Plugin Export**](/deliverables/01-yaml/live-key-auth-plugin-export.md)
* [**Live Key Auth Secret Export Redacted**](/deliverables/01-yaml/live-key-auth-secret-export-redacted.md)
* [**Live Kong Consumer Export**](/deliverables/01-yaml/live-kong-consumer-export.md)
* [**Live Rate Limit Plugin Export**](/deliverables/01-yaml/live-rate-limit-plugin-export.md)
* [**Rate Limit Plugin YAML**](/deliverables/01-yaml/rate-limit-plugin.md)

### **Command Output Evidence**

* [**Kong Endpoint**](/deliverables/02-evidence/00-kong-endpoint.txt)
* [**kubectl get kongplugin**](/deliverables/02-evidence/01-kubectl-get-kongplugin.txt)
* [**kubectl describe ingress**](/deliverables/02-evidence/02-kubectl-describe-ingress-hello-ingress.txt)
* [**kubectl get svc**](/deliverables/02-evidence/03-kubectl-get-svc.txt)
* [**kubectl get pods**](/deliverables/02-evidence/04-kubectl-get-pods.txt)
* [**Kong Controller Logs**](/deliverables/02-evidence/05-kubectl-logs-kong-controller-pod.txt)
* [**k6 Unauthenticated Rate Test**](/deliverables/02-evidence/06-k6-run-rate-test-unauthenticated.txt)
* [**k6 Authenticated Rate Test**](/deliverables/02-evidence/07-k6-run-key-rate-test-authenticated.txt)
* [**401 No API Key Evidence**](/deliverables/02-evidence/08-401-no-api-key-evidence.txt)
* [**200 Valid API Key Evidence**](/deliverables/02-evidence/09-200-valid-api-key-evidence.txt)
* [**429 Authenticated Flood Evidence**](/deliverables/02-evidence/10-429-authenticated-flood-evidence.txt)

### **Short Explanation and Reflection**

* [**Short Explanation and Reflection**](/deliverables/03-explanation/short-explanation-and-reflection.md)

---

## 🧹 **Teardown**

Destroy Kubernetes resources, Kong resources, and Terraform infrastructure:

```bash
chmod +x scripts/3-teardown.sh
./scripts/3-teardown.sh
cd terraform
terraform destroy
```

![teardown-pt1.jpg](/images/teardown-pt1.jpg)
![teardown-pt2.jpg](/images/teardown-pt2.jpg)
![teardown.mp4](/images/teardown.mp4)
![terraform-destroy.jpg](/images/terraform-destroy.jpg)

This script removes:

* Application resources
* Kong plugins
* Kong consumers and credentials
* Ingress resources
* Kong Helm deployment
* Kubernetes namespace resources
* Terraform-managed GCP infrastructure when confirmed

Manual cleanup commands, if needed:

```bash
kubectl delete -f manifests/ --ignore-not-found
helm uninstall kong -n kong
kubectl delete namespace kong --ignore-not-found
cd terraform
terraform destroy
```

Teardown is important because GKE clusters, external load balancers, NAT gateways, and related cloud resources can continue generating cost after the lab is complete.

![teardown-manual.jpg](/images/teardown-manual.jpg)
![terraform-destroy.jpg](/images/terraform-destroy.jpg)

---

## 🧠 **Lessons Learned**

This project reinforced how API gateway controls can protect backend services without requiring application code changes. By enforcing authentication and rate limiting at the Kong Gateway layer, the platform can protect multiple services with a consistent security model.

### **Key Takeaways**

* Authentication verifies who is allowed to access the API.
* Rate limiting controls how much access an authenticated or unauthenticated client receives.
* A valid API key does not prevent abuse by itself; rate limiting is still required.
* KongPlugin resources make gateway behavior declarative and Kubernetes-native.
* k6 provides stronger validation than one-off curl commands because it simulates repeated request pressure.
* Evidence collection is critical for proving that security controls were deployed and tested successfully.

### **Challenges Encountered**

* YAML formatting inside a ConfigMap required careful indentation because the HTML content was embedded directly into `index.html`.
* Kong authentication required the correct relationship between the `KongPlugin`, `KongConsumer`, Kubernetes Secret, and Ingress annotations.
* Rate limiting required repeated request testing to prove the transition from successful requests to `429 Too Many Requests`.
* GKE LoadBalancer provisioning required waiting for the external IP before running gateway tests.

### **Cost Awareness**

After testing was complete, teardown was required to avoid ongoing charges from GKE nodes, external LoadBalancers, Cloud NAT, Artifact Registry, and related Google Cloud networking resources.

---

## 🛠 **Troubleshooting**

### **YAML ConfigMap fails to apply**

Error example:

```text
error converting YAML to JSON: yaml: line 138: could not find expected ':'
```

Common cause:

```text
A multiline HTML block inside index.html was not indented correctly under the ConfigMap block scalar.
```

Fix:

```bash
kubectl apply -f manifests/hello-configmap.yaml
kubectl rollout restart deployment hello -n kong
```

---

### **Kong LoadBalancer endpoint is missing**

```bash
kubectl get svc -n kong
kubectl describe svc -n kong kong-gateway-proxy
```

Wait until the LoadBalancer receives an external IP.

---

### **Request returns 401 Unauthorized**

```bash
curl -i http://<KONG_PROXY_ENDPOINT>/
```

This is expected when no API key is provided. To test authenticated access:

```bash
curl -i -H "apikey: <REDACTED_API_KEY>" http://<KONG_PROXY_ENDPOINT>/
```

---

### **Authenticated request still returns 401**

Check the KongConsumer and credential configuration:

```bash
kubectl get kongconsumer -n kong
kubectl describe kongconsumer -n kong
kubectl get secret -n kong
kubectl describe kongplugin key-auth-plugin -n kong
```

Verify that the Secret is properly labeled for Kong credentials and that the API key header matches the expected key-auth configuration.

---

### **Rate limiting does not return 429**

Check the rate limit plugin and Ingress annotations:

```bash
kubectl get kongplugin -n kong
kubectl describe kongplugin rate-limit-plugin -n kong
kubectl describe ingress hello-ingress -n kong
```

Run a stronger request loop or k6 test:

```bash
k6 run python/key-rate-test.js
bash python/keyloop.sh
```

---

### **Kong Ingress Controller logs**

```bash
kubectl logs -n kong -l app.kubernetes.io/name=ingress-controller
kubectl logs -n kong -l app.kubernetes.io/component=controller
```

---

### **Application pod troubleshooting**

```bash
kubectl get pods -n kong -o wide
kubectl describe pod -n kong <POD_NAME>
kubectl logs -n kong <POD_NAME>
```

### **Terraform troubleshooting**

```bash
cd terraform
terraform fmt -recursive
terraform validate
terraform plan
terraform state list
terraform output
```

---

## 📚 **References**

* [**Google GKE Documentation**](https://cloud.google.com/kubernetes-engine/docs)
* [**Google Cloud SDK Documentation**](https://cloud.google.com/sdk/docs)
* [**Terraform Google Provider Documentation**](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
* [**Kubernetes Documentation**](https://kubernetes.io/docs/)
* [**Kong Ingress Controller Documentation**](https://docs.konghq.com/kubernetes-ingress-controller/)
* [**Kong Rate Limiting Plugin Documentation**](https://docs.konghq.com/hub/kong-inc/rate-limiting/)
* [**Kong Key Authentication Plugin Documentation**](https://docs.konghq.com/hub/kong-inc/key-auth/)
* [**Helm Documentation**](https://helm.sh/docs/)
* [**k6 Documentation**](https://grafana.com/docs/k6/latest/)

---

## 👥 **Author**

| **Field**        | **Value**                                  |
| ---------------- | ------------------------------------------ |
| **Author**       | `T.I.Q.S.`                                 |
| **Group Leader** | `John Sweeney`                             |
| **Group Name**   | `The Brotherhood of jerMutants - Wolfpack` |
| **Version**      | `v1.1`                                     |
| **Date**         | `June 13, 2026`                            |

* **Focus Areas:**
  * Kubernetes
  * API Gateway Security
  * Kong Gateway
  * Terraform
  * Google Kubernetes Engine
  * Platform Engineering
  * Rate Limiting
  * Load Testing

---

## ✅ **Project Status**

### **Status:** Complete

Kong Gateway successfully enforced key authentication and rate limiting for the GKE-hosted backend application. The project includes Terraform infrastructure, Kubernetes manifests, deployment scripts, verification scripts, teardown automation, screenshots, videos, YAML evidence, command output evidence, and a short explanation/reflection document.
