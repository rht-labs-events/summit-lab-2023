# Getting Started

## Installation

1. Start by installing the OpenShift GitOps Operator:

``` 
oc apply -f deploy/bootstrap/operators/openshift-gitops.yaml
oc label ns/openshift-authentication argocd.argoproj.io/managed-by=openshift-gitops
oc label ns/openshift-config argocd.argoproj.io/managed-by=openshift-gitops
```

2. Deploy the ArgoCD applications

```
oc apply -f deploy/lab-content/apps/
```

3. Wait for the following components to be ready:
  - OpenShift GitOps
  - Red Hat SSO
  - OpenShift Dev Spaces

4. Update the 'values.yaml' file and deploy GitLab

Change the following two fields in the gitlab values.yaml file:
  - `route: '<gitlab-fqdn>'` << replace this with the full gitlab fqdn, e.g.: `gitlab.apps.cluster.domain.com`
  - `hosts: 'https://<sso-fqdn>'` << replace this with the SSO fqdn from the above app deployment

Next, deploy gitlab with the following command:

```
helm template deploy/lab-content/gitlab | oc apply -f -
```

Wait for GitLab to fully come up (need 5-10 minutes) before proceeding with the next step.


## Seeding Content and preparing the environment

1. Run the following Ansible Playbook:

```
cd ansible
pip install -r requirements.txt
ansible-playbook -i inventory main.yml -e 'cluster_domain=<cluster id>.p1.openshiftapps.com'
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
