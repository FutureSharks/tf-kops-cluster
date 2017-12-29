echo "== nodeup node config starting =="
ensure-install-dir

cat > cluster_spec.yaml << '__EOF_CLUSTER_SPEC'
cloudConfig: null
docker:
  bridge: ""
  ipMasq: false
  ipTables: false
  logDriver: json-file
  logLevel: warn
  logOpt:
  - max-size=10m
  - max-file=5
  storage: overlay,aufs
  version: 1.13.1
kubeProxy:
  clusterCIDR: 100.96.0.0/11
  cpuRequest: 100m
  featureGates: null
  hostnameOverride: '@aws'
  image: gcr.io/google_containers/kube-proxy:v${kubernetes_version}
  logLevel: 2
kubelet:
  allowPrivileged: true
  cgroupRoot: /
  cloudProvider: aws
  clusterDNS: 100.64.0.10
  clusterDomain: cluster.local
  enableDebuggingHandlers: true
  evictionHard: memory.available<100Mi,nodefs.available<10%,nodefs.inodesFree<5%,imagefs.available<10%,imagefs.inodesFree<5%
  featureGates:
    ExperimentalCriticalPodAnnotation: "true"
  hostnameOverride: '@aws'
  kubeconfigPath: /var/lib/kubelet/kubeconfig
  logLevel: 2
  networkPluginName: cni
  nonMasqueradeCIDR: 100.64.0.0/10
  podInfraContainerImage: gcr.io/google_containers/pause-amd64:3.0
  podManifestPath: /etc/kubernetes/manifests
  requireKubeconfig: true

__EOF_CLUSTER_SPEC
