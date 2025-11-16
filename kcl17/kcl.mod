[package]
name = "kcl"
edition = "v0.11.2"
version = "0.0.2"

[dependencies]
argo-cd = "3.1.8"
crossplane-provider-kubernetes = "0.18.0"
k8s = "1.31.2"
vcluster_config = { git = "https://github.com/SimSimY/kcl-vcluster-config", commit = "3af8de0", version = "0.30.0" }
crossplane-provider-helm = "0.13.2"
