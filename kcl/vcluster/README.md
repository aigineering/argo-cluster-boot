# VCluster KCL Configuration Schema

This directory contains KCL schemas for vCluster configuration, automatically generated from the Go structs in `config.example.go`.

## Files

- **vcluster_config.k**: Complete KCL schema definitions mirroring the vCluster Go configuration structs
- **config_examples.k**: Example configurations demonstrating different use cases
- **main.k**: ArgoCD Application manifest for deploying vCluster

## Schema Overview

The `vcluster_config.k` file contains comprehensive schema definitions for all vCluster configuration options, including:

### Main Configuration Areas

1. **Export KubeConfig** (`ExportKubeConfig`)

   - Configure how vCluster exports the kubeconfig
   - Service account settings
   - Additional secrets

2. **Sync Configuration** (`Sync`)

   - **ToHost**: Resources synced from virtual to host cluster
     - Pods, Secrets, ConfigMaps, Ingresses, Services, etc.
     - Custom resources
     - Namespaces
   - **FromHost**: Resources synced from host to virtual cluster
     - Nodes, Events, Storage classes, CSI resources
     - Custom resources

3. **Integrations** (`Integrations`)

   - Metrics Server
   - KubeVirt
   - External Secrets
   - Cert-Manager
   - Istio

4. **Deploy** (`Deploy`)

   - KubeProxy
   - Metallb
   - CNI (Flannel)
   - Local Path Provisioner
   - Ingress NGINX
   - Metrics Server
   - Volume Snapshot Controller

5. **Networking** (`Networking`)

   - Service and Pod CIDR
   - Service replication
   - DNS resolution
   - Advanced networking options

6. **Policies** (`Policies`)

   - Network policies
   - Pod security standards
   - Resource quotas
   - Limit ranges
   - Central admission control

7. **Control Plane** (`ControlPlane`)

   - Distro selection (K8s/K3s)
   - Backing store (etcd/database)
   - CoreDNS configuration
   - StatefulSet settings
   - High availability
   - Persistence

8. **Private Nodes** (`PrivateNodes`)

   - Kubelet configuration
   - Auto upgrade
   - Auto nodes (static/dynamic pools)
   - VPN settings

9. **RBAC** (`RBAC`)

   - Role configuration
   - Cluster role configuration
   - Volume snapshot rules

10. **Plugins** (`Plugins`)

    - Custom plugin definitions
    - RBAC for plugins

11. **Experimental** (`Experimental`)

    - Deploy manifests
    - Sync settings
    - Deny proxy requests

12. **Sleep Mode** (`SleepMode`)

    - Auto sleep configuration
    - Auto wakeup schedules
    - Timezone settings

13. **Logging** (`Logging`)
    - Log encoding format

## Usage Examples

### Basic Configuration

```kcl
import .vcluster_config as vc

config: vc.Config = {
    controlPlane: {
        distro: {
            k8s: {
                enabled: True
                version: "1.29.0"
            }
        }
        backingStore: {
            database: {
                embedded: {
                    enabled: True
                }
            }
        }
    }
}
```

### High Availability Setup

```kcl
import .vcluster_config as vc

haConfig: vc.Config = {
    controlPlane: {
        distro: {
            k8s: {
                enabled: True
            }
        }
        statefulSet: {
            highAvailability: {
                replicas: 3
            }
            persistence: {
                volumeClaim: {
                    enabled: True
                    size: "20Gi"
                }
            }
        }
        backingStore: {
            etcd: {
                deploy: {
                    enabled: True
                    statefulSet: {
                        highAvailability: {
                            replicas: 3
                        }
                    }
                }
            }
        }
    }
}
```

### Private Nodes with Auto-Scaling

```kcl
import .vcluster_config as vc

privateConfig: vc.Config = {
    privateNodes: {
        enabled: True
        autoNodes: [
            {
                provider: "aws"
                dynamic: [
                    {
                        name: "default-pool"
                        nodeTypeSelector: [
                            {
                                property: "instance.type"
                                operator: "In"
                                values: ["t3.medium", "t3.large"]
                            }
                        ]
                        disruption: {
                            consolidationPolicy: "WhenEmptyOrUnderutilized"
                            consolidateAfter: "5m"
                        }
                    }
                ]
            }
        ]
    }
}
```

### Custom Resource Sync

```kcl
import .vcluster_config as vc

syncConfig: vc.Config = {
    sync: {
        toHost: {
            customResources: {
                "databases.example.com": {
                    enabled: True
                    scope: "Namespaced"
                    patches: [
                        {
                            path: "spec.replicas"
                            expression: "obj.spec.replicas * 2"
                        }
                    ]
                }
            }
        }
    }
}
```

## Important Notes

### Reserved Keywords

KCL has reserved keywords that need to be quoted when used as attribute names. For example:

- `all` → `"all"`

```kcl
# Correct usage
secrets: {
    enabled: True
    "all": False  # Quote the reserved keyword
}
```

### Type Flexibility

Some fields accept multiple types for flexibility:

- `enabled` fields may accept `bool` or `str` (e.g., "auto")
- `StrBool` type: `str | bool`

```kcl
volumeClaim: {
    enabled: "auto"  # Can be "auto", True, or False
}
```

### Image Configuration

Images can be specified as strings or structured objects:

```kcl
# As string
image: "registry.io/repo/image:tag"

# As structured object
image: {
    registry: "registry.io"
    repository: "repo/image"
    tag: "v1.0.0"
}
```

## Reference

For complete details on all configuration options, see:

- [vCluster Documentation](https://www.vcluster.com/docs)
- `config.example.go` - Source Go structs
- `config_examples.k` - Working examples

## Schema Validation

To validate your configuration:

```bash
kcl run your-config.k
```

To validate with the schema explicitly:

```bash
kcl run your-config.k -D import_paths=.
```
