import k8s.api.core.v1 as corev1

oxr = option("params")?.oxr or {}
cm = corev1.ConfigMap {
    metadata: {
        name: "example-configmap"
        namespace: "default"
    }
    data: oxr
}
items = [cm]
