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

## Setting up image-puller to cache needed images

1. Close the image-puller repo to prep for deployment

```
git clone https://github.com/che-incubator/kubernetes-image-puller
cd kubernetes-image-puller/deploy/openshift
```

2. Update the `configmap.yaml` to include the necessary images. In this case, peplace the `IMAGES` entries with the following:

```
udi-rhel8-35=registry.redhat.io/devspaces/udi-rhel8:3.5;
```

3. Deploy the image-puller - note that it's recommend to keep the project/namespace name `k8s-image-puller` for simplicity:

```
oc new-project k8s-image-puller
oc process -f serviceaccount.yaml | oc apply -f -
oc process -f configmap.yaml | oc apply -f -
oc process -f app.yaml | oc apply -f -
```

4. Verify that the images are getting pulled as multiple pods landing on all the nodes in the cluster, i.e.:

```
> oc get nodes
NAME                                         STATUS   ROLES                         AGE    VERSION
ip-10-0-194-222.us-east-2.compute.internal   Ready    control-plane,master,worker   150m   v1.25.7+eab9cc9
ip-10-0-137-105.us-east-2.compute.internal   Ready    worker                        30m    v1.25.7+eab9cc9
ip-10-0-136-111.us-east-2.compute.internal   Ready    worker                        30m    v1.25.7+eab9cc9
ip-10-0-171-109.us-east-2.compute.internal   Ready    worker                        30m    v1.25.7+eab9cc9
> oc get pods
NAME                                       READY   STATUS    RESTARTS       AGE
oc get pods -o wide
NAME                                       READY   STATUS    RESTARTS    AGE     IP             NODE                                         NOMINATED NODE   READINESS GATES
kubernetes-image-puller-6488c9c554-wtgqp   1/1     Running   0           9m38s   10.129.0.35    ip-10-0-137-105.us-east-2.compute.internal   <none>           <none>
kubernetes-image-puller-c795c              1/1     Running   0           9m36s   10.128.0.187   ip-10-0-194-222.us-east-2.compute.internal   <none>           <none>
kubernetes-image-puller-bmk2v              1/1     Running   0           9m36s   10.129.0.36    ip-10-0-137-105.us-east-2.compute.internal   <none>           <none>
kubernetes-image-puller-trk21              1/1     Running   0           7m14s   10.128.0.133   ip-10-0-136-111.us-east-2.compute.internal   <none>           <none>
kubernetes-image-puller-g55hj              1/1     Running   0           7m14s   10.128.0.132   ip-10-0-171-109.us-east-2.compute.internal   <none>           <none>
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
