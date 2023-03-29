# Getting Started

## Installation

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


## Clean-up

1. Start by deleting the checluster application

```
oc delete application -n openshift-gitops checluster
```

2. Delete the OpenShift Dev Spaces Operator

> **TODO:** Avoid the manual clean-up - perhaps by using the `dsc management` tool

```
> oc delete application -n openshift-gitops devspaces
> oc delete subscription -n openshift-operators devworkspace-operator-fast-redhat-operators-openshift-marketplace
> oc delete clusterserviceversion -n openshift-operators devspacesoperator.v3.5.0 \
                                                         devworkspace-operator.v0.19.1
> oc delete crd checlusters.org.eclipse.che \
                devworkspaceoperatorconfigs.controller.devfile.io \
                devworkspaceroutings.controller.devfile.io \
                devworkspaces.workspace.devfile.io \
                devworkspacetemplates.workspace.devfile.io
> oc delete deployment -n openshift-operators devworkspace-webhook-server
> oc delete service -n openshift-operators devworkspace-webhookserver
> oc delete serviceaccount -n openshift-operators devworkspace-webhook-server
> oc delete clusterrole devworkspace-controller-edit-workspaces \
                        devworkspace-controller-metrics-reader \
                        devworkspace-controller-view-workspaces \
                        devworkspace-webhook-server
> oc delete clusterrolebinding devworkspace-webhook-server
```
