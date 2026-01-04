resource "kubectl_manifest" "metrics_server" {

  yaml_body = <<YAML
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: metrics-server
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - cluster: linuxtips-cluster-01
            shard: "01"
          - cluster: linuxtips-cluster-02
            shard: "02"
  template:
    metadata:
      name: metrics-server-{{shard}}
    spec:
      project: "system"
      source:
        repoURL: 'https://kubernetes-sigs.github.io/metrics-server'
        chart: metrics-server
        targetRevision: 3.12.1
        helm:
          releaseName: metrics-server
          values: |
            args:
              - --kubelet-insecure-tls
              - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
            apiService:
              create: true
            serviceMonitor:
              enabled: true
      destination:
        name: '{{ cluster }}'
        namespace: kube-system
        
      syncPolicy:
        syncOptions:
          - CreateNamespace=true
        automated:
          prune: true
          selfHeal: true
YAML

  depends_on = [
    helm_release.argocd
  ]

}