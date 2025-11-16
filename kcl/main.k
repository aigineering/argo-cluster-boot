import k8s.api.core.v1 as corev1
import yaml
import argo_cd.v1alpha1
import models.v1alpha1.infra_pro_techt_io_v1alpha1_v_cluster as vcluster
import vcluster_config.models.values as vc

oxr: vcluster.VCluster = option("params")?.oxr as vcluster.VCluster
spec = oxr.spec.parameters
meta = oxr.metadata

_CC = vc.ClusterConfig {
    exportKubeConfig: {
        secret: {
            name: spec.exportConfig.name
            namespace: spec.exportConfig.namespace
        }
    }
}
app = v1alpha1.Application {
    metadata: {
        name: "vcluster-" + meta.name
        namespace: "argocd"
    }
    spec: {
        project: "default"
        source: {
            repoURL: "https://charts.loft.sh"
            chart: "vcluster"
            targetRevision: spec.vclusterHelmVersion
            helm: {
                values: yaml.encode(_CC)
            }
        }
        # 
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

cm = corev1.ConfigMap {
    metadata: {
        name: meta.name + "-configmap"
        namespace: "default"
    }
    data: {
        app: yaml.encode(app)
        cc: yaml.encode(_CC)
        meta: yaml.encode(oxr.metadata)
        spec: yaml.encode(oxr.spec)
    }
}

items = [cm, app]
