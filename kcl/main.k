import k8s.api.core.v1 as corev1
import yaml
import argo_cd.v1alpha1
import models.v1alpha1.infra_pro_techt_io_v1alpha1_v_cluster as vcluster
import vcluster_config.models.values as vc
import crossplane_provider_kubernetes.v1alpha2 as cp_k8s
import file

_oxr: vcluster.VCluster = option("params")?.oxr or yaml.decode(file.read("input.example.yaml"))
_spec = _oxr.spec.parameters
_meta = _oxr.metadata

_CC = vc.ClusterConfig {
    exportKubeConfig: {
        secret: {
            name: _spec.exportConfig.name
            namespace: _spec.exportConfig.namespace
        }
    }
}
_app = v1alpha1.Application {
    metadata: {
        name: "vcluster-" + _meta.name
        namespace: "argocd"
        annotations: {
            "crossplane.io/composition-resource-name": _meta.name + "-app"
        }
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

_k0 = cp_k8s.Object {
    metadata: {
        name: _meta.name + "-app"
        namespace: "argocd"
        annotations: {
            "crossplane.io/composition-resource-name": _meta.name + "-app-object"
        }
    }
    spec: {
        forProvider: {
            manifest: _app
        }
    }
}
_cm = corev1.ConfigMap {
    metadata: {
        name: _meta.name + "-configmap"
        namespace: "default"
    }
    data: {
        app: yaml.encode(_app)
        cc: yaml.encode(_CC)
        meta: yaml.encode(_oxr.metadata)
        spec: yaml.encode(_oxr.spec)
        ko: yaml.encode(_k0)
    }
}

items = [_k0]
