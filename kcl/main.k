import k8s.api.core.v1 as corev1

cm = corev1.ConfigMap {
    metadata: {
        name: "example-configmap"
        namespace: "default"
    }
    data: {
        "example.key": "example value"
    }
}
items = [cm]
