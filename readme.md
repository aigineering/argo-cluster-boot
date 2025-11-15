# bootstraps cluster with argo and crossplane

used as template for gitops dev of crossplane based features

To sping a new cluster:

```bash
kind delete cluster \
 && kind create cluster \
 && k apply -n argocd -f boostrap/argocd/install.yaml \
 && k apply -f boostrap/\_discovery/self.yaml \
 && sleep 30 \
 && echo -n "argo password: \n" && kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"  |  base64 -d

```

connect to argo:

```
kubectl port-forward svc/argocd-server -n argocd 8080:80 &
```
