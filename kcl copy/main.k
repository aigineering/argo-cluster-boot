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
            exportConfig: {
                name: "tests-secret"
                namespace: "somens"
            }
        }
    }
}
_spec = _config.spec.parameters

_CC = vc.ClusterConfig {
    exportKubeConfig: {
        secret: {
            name: _spec.exportConfig.name
            namespace: _spec.exportConfig.namespace
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
            targetRevision: _spec.vclusterHelmVersion
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
