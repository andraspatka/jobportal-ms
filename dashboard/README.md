# K8s Dashboard

Kubernetes Web Ui Dashboard: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

```
# Deploying the dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# create service account and role bindings
kubectl apply -f dashboard/dashboard-adminuser.yaml

# get the jwt required for logging in
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"

# make the dashboard accessible
kubectl proxy
```

The dashboard will be accessible at the following url: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
