# Project 4 Flux + Splunk Proof Report

Generated: `2026-03-14T21:08:46.347103-07:00`

## Summary

- Required checks passed: **9/9**
- Optional checks passed: **10/11**

Overall required status: **PASS**

## Learning objectives to say out loud

1. GitRepository = “Flux, watch this repo”
2. Kustomization = “Apply this folder continuously”
3. prune=true = “If it’s removed from Git, remove it from cluster”
4. Flux is a reconciler: cluster drift gets corrected back to Git state

## Results

### flux_controllers — PASS

- Description: Verify Flux controllers are running in flux-system.
- Required: Required
- Screenshot required: Yes

```bash
kubectl -n flux-system get pods
```

### **Output 1**

```text
NAME                                           READY   STATUS    RESTARTS   AGE
helm-controller-79684c558d-xjwtn               1/1     Running   0          117m
image-automation-controller-798984bb9c-dzpnn   1/1     Running   0          117m
image-reflector-controller-6fb5d88667-9z6vr    1/1     Running   0          117m
kustomize-controller-65bfd5998b-tzndf          1/1     Running   0          117m
notification-controller-75c87dd876-2w8vc       1/1     Running   0          117m
source-controller-59b8fb78cf-h6r4v             1/1     Running   0          117m
```

### git_source — PASS

- Description: Verify Flux GitRepository source status.
- Required: Required
- Screenshot required: Yes

```bash
flux get sources git -A
```

### **Output 2**

```text
NAMESPACE   NAME            REVISION                SUSPENDED READY MESSAGE                                                
flux-system github-platform project-4@sha1:ea3448c2 False     True  stored artifact for revision 'project-4@sha1:ea3448c2'
```

### git_source_describe — PASS

- Description: Describe the GitRepository backing Flux sync.
- Required: Required
- Screenshot required: Yes

```bash
kubectl -n flux-system describe gitrepository github-platform
```

### **Output 3**

```text
Name:         github-platform
Namespace:    flux-system
Labels:       <none>
Annotations:  reconcile.fluxcd.io/requestedAt: 2026-03-14T21:06:45.5734107-07:00
API Version:  source.toolkit.fluxcd.io/v1
Kind:         GitRepository
Metadata:
  Creation Timestamp:  2026-03-15T02:11:49Z
  Finalizers:
    finalizers.fluxcd.io
  Generation:        1
  Resource Version:  1773547606559135019
  UID:               3662696d-6153-4d56-9cbe-dd6b0014b10d
Spec:
  Interval:  1m
  Ref:
    Branch:  project-4
  Timeout:   60s
  URL:       https://github.com/tiqsclass6/kubernetes-projects-2026.git
Status:
  Artifact:
    Digest:            sha256:2d73a9927b027ec5173ac7cce0f23f6ac5398630f523fd344c7cea42be7a7e53
    Last Update Time:  2026-03-15T02:11:51Z
    Path:              gitrepository/flux-system/github-platform/ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9.tar.gz
    Revision:          project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
    Size:              54175
    URL:               http://source-controller.flux-system.svc.cluster.local./gitrepository/flux-system/github-platform/ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9.tar.gz
  Conditions:
    Last Transition Time:     2026-03-15T02:11:51Z
    Message:                  stored artifact for revision 'project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9'
    Observed Generation:      1
    Reason:                   Succeeded
    Status:                   True
    Type:                     Ready
    Last Transition Time:     2026-03-15T02:11:51Z
    Message:                  stored artifact for revision 'project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9'
    Observed Generation:      1
    Reason:                   Succeeded
    Status:                   True
    Type:                     ArtifactInStorage
  Last Handled Reconcile At:  2026-03-14T21:06:45.5734107-07:00
  Observed Generation:        1
Events:
  Type    Reason                 Age                   From               Message
  ----    ------                 ----                  ----               -------
  Normal  GitOperationSucceeded  42s (x121 over 115m)  source-controller  no changes since last reconcilation: observed revision 'project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9'
```

### kustomizations — PASS

- Description: Verify Flux Kustomization status.
- Required: Required
- Screenshot required: Yes

```bash
flux get kustomizations -A
```

### **Output 4**

```text
NAMESPACE   NAME       REVISION                SUSPENDED READY MESSAGE                                   
flux-system splunk-dev project-4@sha1:ea3448c2 False     True  Applied revision: project-4@sha1:ea3448c2
```

### kustomization_describe — PASS

- Description: Describe the Splunk Flux Kustomization.
- Required: Required
- Screenshot required: Yes

```bash
kubectl -n flux-system describe kustomization splunk-dev
```

### **Output 5**

```text
Name:         splunk-dev
Namespace:    flux-system
Labels:       <none>
Annotations:  reconcile.fluxcd.io/requestedAt: 2026-03-14T21:06:47.9214762-07:00
API Version:  kustomize.toolkit.fluxcd.io/v1
Kind:         Kustomization
Metadata:
  Creation Timestamp:  2026-03-15T02:11:51Z
  Finalizers:
    finalizers.fluxcd.io
  Generation:        1
  Resource Version:  1773547671265791000
  UID:               22d12f9c-a9a0-4fa8-9a3b-0297b680e153
Spec:
  Force:     false
  Interval:  1m
  Path:      ./clusters/dev/splunk
  Prune:     true
  Source Ref:
    Kind:   GitRepository
    Name:   github-platform
  Timeout:  10m
  Wait:     true
Status:
  Conditions:
    Last Transition Time:  2026-03-15T04:07:51Z
    Message:               Applied revision: project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
    Observed Generation:   1
    Reason:                ReconciliationSucceeded
    Status:                True
    Type:                  Ready
    Last Transition Time:  2026-03-15T04:07:51Z
    Message:               Health check passed in 158.818702ms
    Observed Generation:   1
    Reason:                Succeeded
    Status:                True
    Type:                  Healthy
  History:
    Digest:                    sha256:10a6eb040ef3434e38358abf5ed0de5838eba62d3c76411262c35025e7bd8e5f
    First Reconciled:          2026-03-15T02:13:33Z
    Last Reconciled:           2026-03-15T04:07:51Z
    Last Reconciled Duration:  543.715415ms
    Last Reconciled Status:    ReconciliationSucceeded
    Metadata:
      Revision:             project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
    Total Reconciliations:  115
  Inventory:
    Entries:
      Id:                     _splunk-dev__Namespace
      V:                      v1
      Id:                     splunk-dev_splunk-config__ConfigMap
      V:                      v1
      Id:                     splunk-dev_splunk-secret__Secret
      V:                      v1
      Id:                     splunk-dev_splunk__Service
      V:                      v1
      Id:                     splunk-dev_splunk_apps_StatefulSet
      V:                      v1
      Id:                     splunk-dev_splunk-pvc__PersistentVolumeClaim
      V:                      v1
  Last Applied Revision:      project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
  Last Attempted Revision:    project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
  Last Handled Reconcile At:  2026-03-14T21:06:47.9214762-07:00
  Observed Generation:        1
Events:
  Type    Reason                   Age                   From                  Message
  ----    ------                   ----                  ----                  -------
  Normal  ReconciliationSucceeded  38s (x107 over 106m)  kustomize-controller  (combined from similar events): Reconciliation finished in 625.281342ms, next run in 1m0s
```

### splunk_namespace — PASS

- Description: Verify the Flux-managed namespace exists.
- Required: Required
- Screenshot required: Yes

```bash
kubectl get ns
```

### **Output 6**

```text
NAME                                STATUS   AGE
cert-manager                        Active   113m
default                             Active   131m
flux-system                         Active   117m
gke-managed-cim                     Active   128m
gke-managed-networking-dra-driver   Active   127m
gke-managed-system                  Active   128m
gke-managed-volumepopulator         Active   128m
gmp-public                          Active   128m
gmp-system                          Active   128m
ingress-nginx                       Active   114m
kube-node-lease                     Active   131m
kube-public                         Active   131m
kube-system                         Active   131m
splunk-dev                          Active   116m
```

### splunk_resources — PASS

- Description: Verify Splunk pod, service, and PVC.
- Required: Required
- Screenshot required: Yes

```bash
kubectl -n splunk-dev get pods,svc,pvc
```

### **Output 7**

```text
NAME           READY   STATUS    RESTARTS   AGE
pod/splunk-0   1/1     Running   0          116m

NAME             TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
service/splunk   ClusterIP   10.102.4.74   <none>        8091/TCP   116m

NAME                               STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/splunk-pvc   Bound    pvc-4cc36681-e045-4184-9164-bd297b619288   50Gi       RWO            standard-rwo   <unset>                 116m
```

### splunk_statefulset — PASS

- Description: Verify Splunk StatefulSet.
- Required: Required
- Screenshot required: Yes

```bash
kubectl -n splunk-dev get statefulset
```

### **Output 8**

```text
NAME     READY   AGE
splunk   1/1     116m
```

### splunk_pod_describe — PASS

- Description: Describe the Splunk pod for proof/troubleshooting.
- Required: Required
- Screenshot required: No

```bash
kubectl -n splunk-dev describe pod splunk-0
```

### **Output 9**

```text
Name:             splunk-0
Namespace:        splunk-dev
Priority:         0
Service Account:  default
Node:             gke-demo-demo-private-nodes-221d5b96-bwjw/10.100.0.8
Start Time:       Sat, 14 Mar 2026 19:11:54 -0700
Labels:           app=splunk
                  apps.kubernetes.io/pod-index=0
                  controller-revision-hash=splunk-57cf7fff8c
                  statefulset.kubernetes.io/pod-name=splunk-0
Annotations:      <none>
Status:           Running
IP:               10.101.4.22
IPs:
  IP:           10.101.4.22
Controlled By:  StatefulSet/splunk
Containers:
  splunk:
    Container ID:   containerd://3f8cc65ff29558da01e0a54fed48543e9b82d826aa24293046122015056e5516
    Image:          splunk/splunk:latest
    Image ID:       docker.io/splunk/splunk@sha256:4cb755f47d65a8856cd2c5745062e23bbf63dcdf63ad885017fc8c6b0023efb0
    Ports:          8000/TCP (web), 8089/TCP (mgmt), 8088/TCP (hec), 9997/TCP (splunktcp)
    Host Ports:     0/TCP (web), 0/TCP (mgmt), 0/TCP (hec), 0/TCP (splunktcp)
    State:          Running
      Started:      Sat, 14 Mar 2026 19:13:26 -0700
    Ready:          True
    Restart Count:  0
    Environment Variables from:
      splunk-config  ConfigMap  Optional: false
    Environment:
      SPLUNK_PASSWORD:  <set to the key 'SPLUNK_PASSWORD' in secret 'splunk-secret'>  Optional: false
    Mounts:
      /opt/splunk/var from splunk-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-r9tns (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       True 
  ContainersReady             True 
  PodScheduled                True 
Volumes:
  splunk-data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  splunk-pvc
    ReadOnly:   false
  kube-api-access-r9tns:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>
```

### splunk_logs — PASS

- Description: Collect Splunk logs.
- Required: Optional
- Screenshot required: No

```bash
kubectl -n splunk-dev logs splunk-0
```

### **Output 10**

```text
PLAY [Run default Splunk provisioning] *****************************************
Sunday 15 March 2026  02:13:30 +0000 (0:00:00.268)       0:00:00.268 ********** 

TASK [Gathering Facts] *********************************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:35 +0000 (0:00:04.113)       0:00:04.381 ********** 
Sunday 15 March 2026  02:13:35 +0000 (0:00:00.029)       0:00:04.411 ********** 

TASK [Provision role] **********************************************************
Sunday 15 March 2026  02:13:35 +0000 (0:00:00.137)       0:00:04.549 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/get_facts.yml for localhost[0m
Sunday 15 March 2026  02:13:35 +0000 (0:00:00.079)       0:00:04.628 ********** 

TASK [splunk_common : Set privilege escalation user] ***************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:35 +0000 (0:00:00.093)       0:00:04.722 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check for scloud] ****************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:36 +0000 (0:00:00.761)       0:00:05.484 ********** 
Sunday 15 March 2026  02:13:36 +0000 (0:00:00.051)       0:00:05.535 ********** 
Sunday 15 March 2026  02:13:36 +0000 (0:00:00.033)       0:00:05.569 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check for existing installation] *************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:36 +0000 (0:00:00.551)       0:00:06.121 ********** 

TASK [splunk_common : Set splunk install fact] *********************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:36 +0000 (0:00:00.082)       0:00:06.203 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check for existing splunk secret] ************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.518)       0:00:06.721 ********** 

TASK [splunk_common : Set first run fact] **************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.083)       0:00:06.804 ********** 

TASK [splunk_common : Set splunk_build_type fact] ******************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/get_facts_build_type.yml for localhost[0m
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.065)       0:00:06.870 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.035)       0:00:06.906 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.063)       0:00:06.969 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.060)       0:00:07.030 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.057)       0:00:07.088 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.059)       0:00:07.147 ********** 

TASK [splunk_common : Set target version fact] *********************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/get_facts_target_version.yml for localhost[0m
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.088)       0:00:07.236 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.059)       0:00:07.296 ********** 
Sunday 15 March 2026  02:13:37 +0000 (0:00:00.055)       0:00:07.352 ********** 
Sunday 15 March 2026  02:13:38 +0000 (0:00:00.060)       0:00:07.412 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Find manifests] ******************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:38 +0000 (0:00:00.749)       0:00:08.162 ********** 

TASK [splunk_common : Set current version fact] ********************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:38 +0000 (0:00:00.092)       0:00:08.254 ********** 
Sunday 15 March 2026  02:13:38 +0000 (0:00:00.086)       0:00:08.340 ********** 

TASK [splunk_common : Setting upgrade fact] ************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.091)       0:00:08.432 ********** 

TASK [splunk_common : Setting indexer cluster fact from config] ****************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.084)       0:00:08.516 ********** 

TASK [splunk_common : Setting search head cluster fact from config] ************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.085)       0:00:08.602 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.035)       0:00:08.637 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.056)       0:00:08.693 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.055)       0:00:08.749 ********** 

TASK [splunk_common : Detect service name] *************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/get_facts_service_name.yml for localhost[0m
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.074)       0:00:08.823 ********** 

TASK [splunk_common : Setting service_name fact from config] *******************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.085)       0:00:08.908 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.061)       0:00:08.970 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.056)       0:00:09.027 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.111)       0:00:09.138 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.077)       0:00:09.216 ********** 
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.055)       0:00:09.272 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/install_python_requirements.yml for localhost[0m
Sunday 15 March 2026  02:13:39 +0000 (0:00:00.082)       0:00:09.354 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check if requests_unixsocket exists] *********************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:13:41 +0000 (0:00:01.998)       0:00:11.352 ********** 
Sunday 15 March 2026  02:13:42 +0000 (0:00:00.054)       0:00:11.407 ********** 
Sunday 15 March 2026  02:13:42 +0000 (0:00:00.061)       0:00:11.469 ********** 
Sunday 15 March 2026  02:13:42 +0000 (0:00:00.098)       0:00:11.567 ********** 
Sunday 15 March 2026  02:13:42 +0000 (0:00:00.064)       0:00:11.632 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/change_splunk_directory_owner.yml for localhost[0m
Sunday 15 March 2026  02:13:42 +0000 (0:00:00.149)       0:00:11.782 ********** 

TASK [splunk_common : Update Splunk directory owner] ***************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:13:46 +0000 (0:00:03.935)       0:00:15.717 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/update_etc.yml for localhost[0m
Sunday 15 March 2026  02:13:46 +0000 (0:00:00.101)       0:00:15.818 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check if /sbin/updateetc.sh exists] **********************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:47 +0000 (0:00:00.812)       0:00:16.631 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Update /opt/splunk/etc] **********************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:13:51 +0000 (0:00:04.612)       0:00:21.244 ********** 
Sunday 15 March 2026  02:13:51 +0000 (0:00:00.104)       0:00:21.349 ********** 
Sunday 15 March 2026  02:13:52 +0000 (0:00:00.092)       0:00:21.441 ********** 
Sunday 15 March 2026  02:13:52 +0000 (0:00:00.043)       0:00:21.484 ********** 
Sunday 15 March 2026  02:13:52 +0000 (0:00:00.226)       0:00:21.711 ********** 
Sunday 15 March 2026  02:13:52 +0000 (0:00:00.075)       0:00:21.787 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/remove_first_login.yml for localhost[0m
Sunday 15 March 2026  02:13:52 +0000 (0:00:00.087)       0:00:21.874 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Create .ui_login] ****************************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:13:53 +0000 (0:00:00.787)       0:00:22.662 ********** 
Sunday 15 March 2026  02:13:53 +0000 (0:00:00.057)       0:00:22.719 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/set_splunk_secret.yml for localhost[0m
Sunday 15 March 2026  02:13:53 +0000 (0:00:00.102)       0:00:22.821 ********** 
Sunday 15 March 2026  02:13:53 +0000 (0:00:00.058)       0:00:22.880 ********** 
Sunday 15 March 2026  02:13:53 +0000 (0:00:00.038)       0:00:22.918 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/enable_admin_auth.yml for localhost[0m
Sunday 15 March 2026  02:13:53 +0000 (0:00:00.201)       0:00:23.120 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Hash the password] ***************************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:13:55 +0000 (0:00:01.297)       0:00:24.417 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Generate user-seed.conf (Linux)] *************************
[0;33mchanged: [localhost] => (item=USERNAME)[0m
[0;33mchanged: [localhost] => (item=HASHED_PASSWORD)[0m
Sunday 15 March 2026  02:13:56 +0000 (0:00:01.294)       0:00:25.712 ********** 
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.085)       0:00:25.798 ********** 
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.103)       0:00:25.902 ********** 
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.082)       0:00:25.984 ********** 
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.075)       0:00:26.059 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/configure_mgmt_port.yml for localhost[0m
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.091)       0:00:26.150 ********** 

TASK [splunk_common : set version fact] ****************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.092)       0:00:26.243 ********** 
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.037)       0:00:26.280 ********** 
Sunday 15 March 2026  02:13:56 +0000 (0:00:00.078)       0:00:26.359 ********** 
Sunday 15 March 2026  02:13:57 +0000 (0:00:00.038)       0:00:26.398 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/pre_splunk_start_commands.yml for localhost[0m
Sunday 15 March 2026  02:13:57 +0000 (0:00:00.087)       0:00:26.486 ********** 
Sunday 15 March 2026  02:13:57 +0000 (0:00:00.055)       0:00:26.542 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/enable_s2s.yml for localhost[0m
Sunday 15 March 2026  02:13:57 +0000 (0:00:00.098)       0:00:26.640 ********** 
Sunday 15 March 2026  02:13:57 +0000 (0:00:00.082)       0:00:26.723 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/s2s/configure_splunktcp.yml for localhost[0m
Sunday 15 March 2026  02:13:57 +0000 (0:00:00.102)       0:00:26.825 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Enable splunktcp input] **********************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:13:58 +0000 (0:00:00.594)       0:00:27.420 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Remove splunktcp-ssl input] ******************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:58 +0000 (0:00:00.584)       0:00:28.005 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Remove input SSL settings] *******************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:59 +0000 (0:00:00.560)       0:00:28.566 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Reset root CA] *******************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:13:59 +0000 (0:00:00.539)       0:00:29.105 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/trigger_restart.yml for localhost[0m
Sunday 15 March 2026  02:13:59 +0000 (0:00:00.075)       0:00:29.181 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/get_splunk_status.yml for localhost[0m
Sunday 15 March 2026  02:13:59 +0000 (0:00:00.052)       0:00:29.233 ********** 

TASK [splunk_common : Restrict permissions on splunk.key for Status] ***********
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/restrict_permissions.yml for localhost => (item=/opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key)[0m
Sunday 15 March 2026  02:13:59 +0000 (0:00:00.064)       0:00:29.297 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check if /opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key exists] ***
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:00 +0000 (0:00:00.701)       0:00:29.998 ********** 
Sunday 15 March 2026  02:14:00 +0000 (0:00:00.040)       0:00:30.038 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Get Splunk status] ***************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:05 +0000 (0:00:05.066)       0:00:35.105 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Trigger restart] *****************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:06 +0000 (0:00:01.121)       0:00:36.227 ********** 
Sunday 15 March 2026  02:14:06 +0000 (0:00:00.074)       0:00:36.301 ********** 
Sunday 15 March 2026  02:14:07 +0000 (0:00:00.109)       0:00:36.410 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/set_mgmt_port.yml for localhost[0m
Sunday 15 March 2026  02:14:07 +0000 (0:00:00.161)       0:00:36.572 ********** 

TASK [splunk_common : Set localhost address for mgmt port] *********************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:07 +0000 (0:00:00.160)       0:00:36.733 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Set mgmt port] *******************************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:14:08 +0000 (0:00:01.398)       0:00:38.132 ********** 
Sunday 15 March 2026  02:14:08 +0000 (0:00:00.057)       0:00:38.189 ********** 
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.238)       0:00:38.427 ********** 
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.048)       0:00:38.476 ********** 
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.119)       0:00:38.595 ********** 
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.081)       0:00:38.677 ********** 
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.063)       0:00:38.740 ********** 
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.093)       0:00:38.834 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/enable_splunkd_ssl.yml for localhost[0m
Sunday 15 March 2026  02:14:09 +0000 (0:00:00.105)       0:00:38.940 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Enable Splunkd SSL] **************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.843)       0:00:39.783 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.058)       0:00:39.842 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.039)       0:00:39.882 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.040)       0:00:39.923 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.039)       0:00:39.962 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.088)       0:00:40.051 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.100)       0:00:40.152 ********** 
Sunday 15 March 2026  02:14:10 +0000 (0:00:00.040)       0:00:40.193 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/start_splunk.yml for localhost[0m
Sunday 15 March 2026  02:14:11 +0000 (0:00:00.203)       0:00:40.396 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/get_splunk_status.yml for localhost[0m
Sunday 15 March 2026  02:14:11 +0000 (0:00:00.106)       0:00:40.503 ********** 

TASK [splunk_common : Restrict permissions on splunk.key for Status] ***********
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/restrict_permissions.yml for localhost => (item=/opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key)[0m
Sunday 15 March 2026  02:14:11 +0000 (0:00:00.125)       0:00:40.629 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check if /opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key exists] ***
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:12 +0000 (0:00:00.878)       0:00:41.507 ********** 
Sunday 15 March 2026  02:14:12 +0000 (0:00:00.078)       0:00:41.586 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Get Splunk status] ***************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:13 +0000 (0:00:01.110)       0:00:42.697 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Cleanup Splunk runtime files] ****************************
[0;32mok: [localhost] => (item=/opt/splunk/var/run/splunk/splunkd.pid)[0m
[0;32mok: [localhost] => (item=/opt/splunk/var/lib/splunk/kvstore/mongo/mongod.lock)[0m
Sunday 15 March 2026  02:14:15 +0000 (0:00:02.087)       0:00:44.784 ********** 

TASK [splunk_common : Restrict permissions on splunk.key] **********************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/restrict_permissions.yml for localhost => (item=/opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key)[0m
Sunday 15 March 2026  02:14:15 +0000 (0:00:00.112)       0:00:44.897 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check if /opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key exists] ***
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:14:16 +0000 (0:00:01.088)       0:00:45.986 ********** 
Sunday 15 March 2026  02:14:16 +0000 (0:00:00.079)       0:00:46.065 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Start Splunk via CLI] ************************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:15:36 +0000 (0:01:19.428)       0:02:05.493 ********** 
Sunday 15 March 2026  02:15:36 +0000 (0:00:00.194)       0:02:05.688 ********** 
Sunday 15 March 2026  02:15:36 +0000 (0:00:00.111)       0:02:05.799 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/check_uds_file.yml for localhost[0m
Sunday 15 March 2026  02:15:36 +0000 (0:00:00.095)       0:02:05.895 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Check if UDS file exists] ********************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:37 +0000 (0:00:00.771)       0:02:06.667 ********** 

TASK [splunk_common : Set UDS enabled/disabled] ********************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:37 +0000 (0:00:00.088)       0:02:06.755 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Wait for splunkd management port] ************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:39 +0000 (0:00:01.695)       0:02:08.451 ********** 
Sunday 15 March 2026  02:15:39 +0000 (0:00:00.062)       0:02:08.513 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/set_certificate_prefix.yml for localhost[0m
Sunday 15 March 2026  02:15:39 +0000 (0:00:00.269)       0:02:08.783 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Test basic https endpoint] *******************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:41 +0000 (0:00:02.568)       0:02:11.352 ********** 

TASK [splunk_common : Set url prefix for future REST calls] ********************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:42 +0000 (0:00:00.101)       0:02:11.453 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/clean_user_seed.yml for localhost[0m
Sunday 15 March 2026  02:15:42 +0000 (0:00:00.175)       0:02:11.629 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Remove user-seed.conf] ***********************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:43 +0000 (0:00:00.918)       0:02:12.548 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/add_splunk_license.yml for localhost[0m
Sunday 15 March 2026  02:15:43 +0000 (0:00:00.203)       0:02:12.751 ********** 

TASK [splunk_common : Initialize licenses array] *******************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:43 +0000 (0:00:00.200)       0:02:12.951 ********** 

TASK [splunk_common : Determine available licenses] ****************************
[0;32mok: [localhost] => (item=splunk.lic)[0m
Sunday 15 March 2026  02:15:43 +0000 (0:00:00.302)       0:02:13.254 ********** 

TASK [splunk_common : Apply licenses] ******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/apply_licenses.yml for localhost => (item=splunk.lic)[0m
Sunday 15 March 2026  02:15:44 +0000 (0:00:00.285)       0:02:13.539 ********** 
Sunday 15 March 2026  02:15:44 +0000 (0:00:00.219)       0:02:13.759 ********** 
Sunday 15 March 2026  02:15:44 +0000 (0:00:00.172)       0:02:13.932 ********** 
Sunday 15 March 2026  02:15:44 +0000 (0:00:00.233)       0:02:14.165 ********** 

TASK [splunk_common : include_tasks] *******************************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/licenses/add_license.yml for localhost => (item=(censored due to no_log))[0m
Sunday 15 March 2026  02:15:45 +0000 (0:00:00.252)       0:02:14.418 ********** 
Sunday 15 March 2026  02:15:45 +0000 (0:00:00.104)       0:02:14.522 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_common : Ensure license path] *************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:45 +0000 (0:00:00.796)       0:02:15.321 ********** 
Sunday 15 March 2026  02:15:45 +0000 (0:00:00.046)       0:02:15.368 ********** 
Sunday 15 March 2026  02:15:46 +0000 (0:00:00.068)       0:02:15.437 ********** 
Sunday 15 March 2026  02:15:46 +0000 (0:00:00.038)       0:02:15.475 ********** 
Sunday 15 March 2026  02:15:46 +0000 (0:00:00.087)       0:02:15.562 ********** 
Sunday 15 March 2026  02:15:46 +0000 (0:00:00.067)       0:02:15.630 ********** 
Sunday 15 March 2026  02:15:46 +0000 (0:00:00.131)       0:02:15.761 ********** 

TASK [splunk_standalone : include_tasks] ***************************************
[0;36mincluded: /opt/ansible/roles/splunk_standalone/tasks/../../splunk_common/tasks/set_as_hec_receiver.yml for localhost[0m
Sunday 15 March 2026  02:15:46 +0000 (0:00:00.103)       0:02:15.865 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_standalone : Get existing HEC token] ******************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:15:50 +0000 (0:00:04.090)       0:02:19.955 ********** 

TASK [splunk_standalone : Attempt] *********************************************
[0;32mok: [localhost] => {}[0m
[0;32m[0m
[0;32mMSG:[0m
[0;32m[0m
[0;32m404[0m
Sunday 15 March 2026  02:15:50 +0000 (0:00:00.091)       0:02:20.047 ********** 
Sunday 15 March 2026  02:15:50 +0000 (0:00:00.096)       0:02:20.143 ********** 
Sunday 15 March 2026  02:15:50 +0000 (0:00:00.075)       0:02:20.219 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_standalone : Setup global HEC] ************************************
[0;33mchanged: [localhost][0m
Sunday 15 March 2026  02:15:52 +0000 (0:00:01.612)       0:02:21.831 ********** 
Sunday 15 March 2026  02:15:52 +0000 (0:00:00.070)       0:02:21.902 ********** 
Sunday 15 March 2026  02:15:52 +0000 (0:00:00.060)       0:02:21.962 ********** 
Sunday 15 March 2026  02:15:52 +0000 (0:00:00.098)       0:02:22.060 ********** 
Sunday 15 March 2026  02:15:52 +0000 (0:00:00.138)       0:02:22.198 ********** 
Sunday 15 March 2026  02:15:52 +0000 (0:00:00.145)       0:02:22.344 ********** 
Sunday 15 March 2026  02:15:53 +0000 (0:00:00.054)       0:02:22.399 ********** 
Sunday 15 March 2026  02:15:53 +0000 (0:00:00.069)       0:02:22.468 ********** 
Sunday 15 March 2026  02:15:53 +0000 (0:00:00.106)       0:02:22.574 ********** 

TASK [splunk_standalone : include_tasks] ***************************************
[0;36mincluded: /opt/ansible/roles/splunk_standalone/tasks/../../splunk_common/tasks/check_for_required_restarts.yml for localhost[0m
Sunday 15 March 2026  02:15:53 +0000 (0:00:00.076)       0:02:22.651 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [splunk_standalone : Check for required restarts] *************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:55 +0000 (0:00:02.202)       0:02:24.853 ********** 
Sunday 15 March 2026  02:15:55 +0000 (0:00:00.043)       0:02:24.897 ********** 

TASK [Check all instances for required restarts] *******************************
[0;36mincluded: /opt/ansible/roles/splunk_common/tasks/check_for_required_restarts.yml for localhost[0m
Sunday 15 March 2026  02:15:55 +0000 (0:00:00.147)       0:02:25.045 ********** 
[1;35m[WARNING]: Using world-readable permissions for temporary files Ansible needs[0m
[1;35mto create when becoming an unprivileged user. This may be insecure. For[0m
[1;35minformation on securing this, see https://docs.ansible.com/ansible-[0m
[1;35mcore/2.15/playbook_guide/playbooks_privilege_escalation.html#risks-of-becoming-[0m
[1;35man-unprivileged-user#risks-of-becoming-an-unprivileged-user[0m

TASK [Check for required restarts] *********************************************
[0;32mok: [localhost][0m
Sunday 15 March 2026  02:15:56 +0000 (0:00:01.182)       0:02:26.227 ********** 

PLAY RECAP *********************************************************************
[0;33mlocalhost[0m                  : [0;32mok=82  [0m [0;33mchanged=11  [0m unreachable=0    failed=0    [0;36mskipped=82  [0m rescued=0    ignored=0   

Sunday 15 March 2026  02:15:56 +0000 (0:00:00.053)       0:02:26.280 ********** 
=============================================================================== 
splunk_common : Start Splunk via CLI ----------------------------------- 79.43s
splunk_common : Get Splunk status --------------------------------------- 5.07s
splunk_common : Update /opt/splunk/etc ---------------------------------- 4.61s
Gathering Facts --------------------------------------------------------- 4.11s
splunk_standalone : Get existing HEC token ------------------------------ 4.09s
splunk_common : Update Splunk directory owner --------------------------- 3.94s
splunk_common : Test basic https endpoint ------------------------------- 2.57s
splunk_standalone : Check for required restarts ------------------------- 2.20s
splunk_common : Cleanup Splunk runtime files ---------------------------- 2.09s
splunk_common : Check if requests_unixsocket exists --------------------- 2.00s
splunk_common : Wait for splunkd management port ------------------------ 1.70s
splunk_standalone : Setup global HEC ------------------------------------ 1.61s
splunk_common : Set mgmt port ------------------------------------------- 1.40s
splunk_common : Hash the password --------------------------------------- 1.30s
splunk_common : Generate user-seed.conf (Linux) ------------------------- 1.30s
Check for required restarts --------------------------------------------- 1.18s
splunk_common : Trigger restart ----------------------------------------- 1.12s
splunk_common : Get Splunk status --------------------------------------- 1.11s
splunk_common : Check if /opt/splunk/var/lib/splunk/kvstore/mongo/splunk.key exists --- 1.09s
splunk_common : Remove user-seed.conf ----------------------------------- 0.92s
===============================================================================

Ansible playbook complete, will begin streaming splunkd_stderr.log
```

### ingress_nginx_pods — PASS

- Description: Verify ingress-nginx controller pods.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl -n ingress-nginx get pods
```

### **Output 11**

```text
NAME                                        READY   STATUS    RESTARTS   AGE
ingress-nginx-controller-5cff7d769c-445hd   1/1     Running   0          114m
```

### ingress_nginx_service — PASS

- Description: Verify ingress-nginx controller service.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl -n ingress-nginx get svc
```

### **Output 12**

```text
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.102.8.102   34.132.156.189   80:30688/TCP,443:32473/TCP   114m
ingress-nginx-controller-admission   ClusterIP      10.102.7.86    <none>           443/TCP                      114m
```

### cert_manager_pods — PASS

- Description: Verify cert-manager pods.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl -n cert-manager get pods
```

### **Output 13**

```text
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-66487b786-5zktr               1/1     Running   0          113m
cert-manager-cainjector-65fdc9b9d7-8f75h   1/1     Running   0          113m
cert-manager-webhook-7d96469bf8-lb8tr      1/1     Running   0          113m
```

### cert_manager_crds — PASS

- Description: Verify cert-manager CRDs are installed.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl get crd | grep cert-manager
```

### **Output 14**

```text
certificaterequests.cert-manager.io                    2026-03-15T02:14:36Z
certificates.cert-manager.io                           2026-03-15T02:14:36Z
challenges.acme.cert-manager.io                        2026-03-15T02:14:35Z
clusterissuers.cert-manager.io                         2026-03-15T02:14:37Z
issuers.cert-manager.io                                2026-03-15T02:14:37Z
orders.acme.cert-manager.io                            2026-03-15T02:14:35Z
```

### splunk_ingress — PASS

- Description: Verify Splunk ingress object.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl -n splunk-dev get ingress
```

### **Output 15**

```text
No resources found in splunk-dev namespace.
```

### cluster_issuers — PASS

- Description: Verify ClusterIssuer resources.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl get clusterissuer
```

### **Output 16**

```text
No resources found
```

### tls_secret — FAIL

- Description: Verify TLS secret exists.
- Required: Optional
- Screenshot required: Yes

```bash
kubectl -n splunk-dev get secret splunk-web-tls
```

### **Errors 1**

```text
Error from server (NotFound): secrets "splunk-web-tls" not found
```

### flux_reconcile_source — PASS

- Description: Force Flux Git source reconciliation.
- Required: Optional
- Screenshot required: Yes

```bash
flux reconcile source git github-platform -n flux-system
```

### **Output 17**

```text
► annotating GitRepository github-platform in flux-system namespace
✔ GitRepository annotated
◎ waiting for GitRepository reconciliation
✔ fetched revision project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
```

### flux_reconcile_kustomization — PASS

- Description: Force Flux Kustomization reconciliation.
- Required: Optional
- Screenshot required: Yes

```bash
flux reconcile kustomization splunk-dev -n flux-system --with-source
```

### **Output 18**

```text
► annotating GitRepository github-platform in flux-system namespace
✔ GitRepository annotated
◎ waiting for GitRepository reconciliation
✔ fetched revision project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
► annotating Kustomization splunk-dev in flux-system namespace
✔ Kustomization annotated
◎ waiting for Kustomization reconciliation
✔ applied revision project-4@sha1:ea3448c2cb9f31b8aaf83befe3ec49bd3bcdcbd9
```

### localhost_8091 — PASS

- Description: Check whether localhost:8091 is reachable for Splunk UI.
- Required: Optional
- Screenshot required: Yes

```bash
socket check to 127.0.0.1:8091
```

### **Output 19**

```text
localhost:8091 is reachable
```
