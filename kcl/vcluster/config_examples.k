"""
Example VCluster Configuration
This demonstrates how to use the vcluster_config schema
"""

import .vcluster_config as vc

# Example 1: Basic vCluster configuration
basicConfig: vc.Config = {
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
        statefulSet: {
            image: {
                repository: "loft-sh/vcluster"
                tag: "0.20.0"
            }
            resources: {
                limits: {
                    cpu: "1000m"
                    memory: "1Gi"
                }
                requests: {
                    cpu: "200m"
                    memory: "256Mi"
                }
            }
        }
    }
    sync: {
        toHost: {
            pods: {
                enabled: True
            }
            secrets: {
                enabled: True
                "all": False
            }
            configMaps: {
                enabled: True
                "all": False
            }
        }
        fromHost: {
            nodes: {
                enabled: True
                selector: {
                    "all": True
                }
            }
        }
    }
}

# Example 2: Private Nodes configuration
privateNodesConfig: vc.Config = {
    privateNodes: {
        enabled: True
        kubelet: {
            config: {
                maxPods: 110
            }
        }
        autoNodes: [
            {
                provider: "aws"
                properties: {
                    region: "us-west-2"
                }
                static: [
                    {
                        name: "worker-pool"
                        quantity: 3
                        nodeTypeSelector: [
                            {
                                property: "instance.type"
                                operator: "In"
                                values: ["t3.medium", "t3.large"]
                            }
                        ]
                    }
                ]
            }
        ]
    }
    controlPlane: {
        distro: {
            k8s: {
                enabled: True
            }
        }
    }
}

# Example 3: Advanced networking and integrations
advancedConfig: vc.Config = {
    networking: {
        serviceCIDR: "10.96.0.0/16"
        podCIDR: "10.244.0.0/16"
        resolveDNS: [
            {
                hostname: "database"
                service: "postgres"
                namespace: "default"
                target: {
                    hostService: "database/postgres-host"
                }
            }
        ]
    }
    integrations: {
        metricsServer: {
            enabled: True
            nodes: True
            pods: True
        }
        certManager: {
            enabled: True
            sync: {
                toHost: {
                    certificates: {
                        enabled: True
                    }
                    issuers: {
                        enabled: True
                    }
                }
            }
        }
    }
    controlPlane: {
        distro: {
            k8s: {
                enabled: True
            }
        }
        coredns: {
            enabled: True
            deployment: {
                replicas: 2
                resources: {
                    requests: {
                        cpu: "50m"
                        memory: "128Mi"
                    }
                }
            }
        }
    }
}

# Example 4: High availability setup
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
                leaseDuration: 15
                renewDeadline: 10
                retryPeriod: 2
            }
            persistence: {
                volumeClaim: {
                    enabled: True
                    size: "20Gi"
                    storageClass: "fast-ssd"
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
                        persistence: {
                            volumeClaim: {
                                enabled: True
                                size: "10Gi"
                            }
                        }
                    }
                }
            }
        }
    }
}

# Example 5: Sleep mode configuration
sleepModeConfig: vc.Config = {
    sleepMode: {
        enabled: True
        timeZone: "America/New_York"
        autoSleep: {
            afterInactivity: "1h"
            # Sleep at 7 PM
            schedule: "0 19 * * *"
        }
        autoWakeup: {
            # Wake at 8 AM on weekdays
            schedule: "0 8 * * 1-5"
        }
    }
    controlPlane: {
        distro: {
            k8s: {
                enabled: True
            }
        }
    }
}

# Example 6: Sync with custom resources
customResourceSyncConfig: vc.Config = {
    sync: {
        toHost: {
            customResources: {
                "databases.example.com": {
                    enabled: True
                    scope: "Namespaced"
                }
                "queues.messaging.example.com": {
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
        fromHost: {
            storageClasses: {
                enabled: "auto"
                selector: {
                    matchLabels: {
                        "vcluster-sync": "true"
                    }
                }
            }
        }
    }
    controlPlane: {
        distro: {
            k8s: {
                enabled: True
            }
        }
    }
}
