# Getting Started

1. Start by installing the OpenShift GitOps Operator:

``` 
oc apply -f deploy/bootstrap/operators/openshift-gitops.yaml
```

2. Next, apply the CheCluster ArgoCD Application to spin up RH OpenShift Dev Spaces:

```
oc apply -f deploy/lab-content/apps/
```

> **NOTE:** The following may not be needed for the Lab:

3. Now set up the Lab space specific ArgoCD instance to be used to manage Lab content:

```
oc apply -f deploy/lab-content/gitops/argocd.yaml 
```

