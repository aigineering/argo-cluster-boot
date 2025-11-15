import argo_cd.v1alpha1
import crossplane_provider_kubernetes.v1alpha2

v1alpha1.Application {
    metadata: {
        name: "vcluster"
        namespace: "argocd"
    }
    spec: {
        project: "default"
        source: {
            repoURL: "https://charts.loft.sh"
            chart: "vcluster"
            targetRevision: "0.15.1"
            helm: {}
        }
        destination: {
            server: "https://kubernetes.default.svc"
            namespace: "vcluster"
        }
        syncPolicy: {
            automated: {
                prune: False
                selfHeal: True
            }
        }
    }
}
