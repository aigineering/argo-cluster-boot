import k8s.api.core.v1 as corev1
import yaml
import argo_cd.v1alpha1
import models.v1alpha1.infra_pro_techt_io_v1alpha1_v_cluster as vcluster

oxr: vcluster.VCluster = option("params")?.oxr as vcluster.VCluster
spec = oxr.spec.parameters
cm = corev1.ConfigMap {
    metadata: {
        name: "example-configmap"
        namespace: "default"
    }
    data: {
        data: yaml.encode(spec)
    }
}

# application = v1alpha1.Application {
#     metadata: {
#         name: "vcluster-" + _config.metadata.name
#         namespace: "argocd"
#     }
#     spec: {
#         project: "default"
#         source: {
#             repoURL: "https://charts.loft.sh"
#             chart: "vcluster"
#             targetRevision: _spec.vclusterHelmVersion
#             helm: {
#                 values: yaml.encode(_CC)
#             }
#         }
#         # 
#         destination: {
#             server: "https://kubernetes.default.svc"
#             namespace: "vcluster"
#         }
#         syncPolicy: {
#             automated: {
#                 prune: False
#                 selfHeal: True
#             }
#         }
#     }
# }
items = [cm]
