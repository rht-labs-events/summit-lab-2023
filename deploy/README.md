# Getting Started

1. Start by installing the OpenShift GitOps Operator:

``` 
oc apply -f deploy/bootstrap/operators/openshift-gitops.yaml
```

2. Next, apply the CheCluster ArgoCD Application to spin up RH OpenShift Dev Spaces:

```
oc apply -f deploy/lab-content/apps/checluster.yaml 
```

> **_NOTE:_** The deployment seems to fail to apply the correct label to the namespace it creates and hence causes ArgoCD App sync to fail with lack of permissions. The following namespace label fixes this issue:

```
apiVersion: v1
kind: Namespace
metadata:
  name: openshift-devspaces
  labels:
    argocd.argoproj.io/managed-by: openshift-gitops
```

3. Now set up the Lab space / specific ArgoCD instance to be used to manage Lab content: 

```
oc apply -f deploy/lab-content/gitops/argocd.yaml 
```

