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
  version: ${docker_version}
encryptionConfig: null
kubeAPIServer:
  address: 127.0.0.1
  admissionControl:
  - Initializers
  - NamespaceLifecycle
  - LimitRanger
  - ServiceAccount
  - PersistentVolumeLabel
  - DefaultStorageClass
  - DefaultTolerationSeconds
  - NodeRestriction
  - Priority
  - ResourceQuota
  allowPrivileged: true
  anonymousAuth: false
  apiServerCount: ${master_count}
  authorizationMode: AlwaysAllow
  cloudProvider: aws
  etcdServers:
  - http://127.0.0.1:4001
  etcdServersOverrides:
  - /events#http://127.0.0.1:4002
  image: gcr.io/google_containers/kube-apiserver:v${kubernetes_version}
  insecurePort: 8080
  kubeletPreferredAddressTypes:
  - InternalIP
  - Hostname
  - ExternalIP
  logLevel: 2
  requestheaderAllowedNames:
  - aggregator
  requestheaderExtraHeaderPrefixes:
  - X-Remote-Extra-
  requestheaderGroupHeaders:
  - X-Remote-Group
  requestheaderUsernameHeaders:
  - X-Remote-User
  securePort: 443
  serviceClusterIPRange: 100.64.0.0/13
  storageBackend: etcd2
kubeControllerManager:
  allocateNodeCIDRs: true
  attachDetachReconcileSyncPeriod: 1m0s
  cloudProvider: aws
  clusterCIDR: 100.96.0.0/11
  clusterName: ${cluster_fqdn}
  configureCloudRoutes: false
  image: gcr.io/google_containers/kube-controller-manager:v${kubernetes_version}
  leaderElection:
    leaderElect: true
  logLevel: 2
  useServiceAccountCredentials: true
kubeProxy:
  clusterCIDR: 100.96.0.0/11
  cpuRequest: 100m
  featureGates: null
  hostnameOverride: '@aws'
  image: gcr.io/google_containers/kube-proxy:v${kubernetes_version}
  logLevel: 2
kubeScheduler:
  image: gcr.io/google_containers/kube-scheduler:v${kubernetes_version}
  leaderElection:
    leaderElect: true
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
masterKubelet:
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
  registerSchedulable: false
  requireKubeconfig: true

__EOF_CLUSTER_SPEC
