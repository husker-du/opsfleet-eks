nodeSelector:
  karpenter.sh/controller: 'true'
settings:
  clusterName: ${cluster_name}
  clusterEndpoint: ${cluster_endpoint}
  interruptionQueue: ${queue_name}
tolerations:
  - key: CriticalAddonsOnly
    operator: Exists
  - key: karpenter.sh/controller
    operator: Exists
    effect: NoSchedule
webhook:
  enabled: false
