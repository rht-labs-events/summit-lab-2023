#!/bin/bash
#
# Helper script to populate X number of users with a passwd xyz
#

password=$1

# Clean-up before re-populating the same file
rm -f lab_users.yaml

#  Loop through all users to create the necessary content
for i in {1..60}
do
  cat << EOF >> lab_users.yaml
---
kind: KeycloakUser
apiVersion: keycloak.org/v1alpha1
metadata:
  name: user-$i
  namespace: devspaces-lab-sso
  finalizers:
    - user.cleanup
  labels:
    app: devspaces-lab-sso-user-$i
spec:
  realmSelector:
    matchLabels:
      app: devspaces-lab-sso
  user:
    credentials:
      - type: password
        value: ${password}
    email: user$i@example.com
    enabled: true
    firstName: User
    lastName: "$i"
    username: user$i
---
kind: Namespace
apiVersion: v1
metadata:
  name: user${i}-devspaces
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: admin-local
  namespace: user${i}-devspaces
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: User
  name: user${i}
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: cluster-reader-user-${i}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-reader
subjects:
  - kind: User
    apiGroup: rbac.authorization.k8s.io
    name: user${i}
EOF
done
