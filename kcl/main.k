import argo_cd.v1alpha1
import crossplane_provider_kubernetes.v1alpha2
import yaml
import vcluster_config.models.values as vc
import models.v1alpha1.infra_pro_techt_io_v1alpha1_v_cluster as vcluster

_config = vcluster.VCluster {
    metadata: {
        name: "testss"
        namespace: "default"
    }
    spec: {
        parameters: {
            clusterName: "test-cluster"
        }
    }
}
_spec = _config.spec

_CC = vc.ClusterConfig {
    exportKubeConfig: {
        secret: {
            name: "testss"
        }
    }
}
v1alpha1.Application {
    metadata: {
        name: "vcluster-" + _config.metadata.name
        namespace: "argocd"
    }
    spec: {
        project: "default"
        source: {
            repoURL: "https://charts.loft.sh"
            chart: "vcluster"
            targetRevision: _spec.parameters.vclusterHelmVersion
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
