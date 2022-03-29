# Use external ceph cluster in Kubernetes

This is a guide for connecting external ceph cluster to k8s using [Ceph CSI](https://github.com/ceph/ceph-csi). Ceph CSI plugins implement an interface between Kubernetes and Ceph cluster. Independent CSI plugins are provided to support RBD and CephFS backed volumes.

## 1. Gather the following information from the ceph cluster

### 1-1. Change working directory on the node where the ceph cluster is installed

```shell script
$ cd /etc/ceph
```

### 1-2. Ceph cluster fsid and monitor list

```shell script
$ cat ceph.conf
[global]
	fsid = 50611be6-33b3-11eb-a5cb-0894ef32cba4
	mon_host = v2:172.21.3.8:3300/0,v1:172.21.3.8:6789/0
```

### 1-3. Key of the admin client

```shell script
$ cat ceph.client.admin.keyring
[client.admin]
	key = AQCeBcZftAEvExAAultsKBpNpiWWGi06Md7mmw==
```

### 1-4. Name of the pool to be used for rbd

```shell script
$ ceph osd lspools
1 device_health_metrics
2 test-pool
3 rbd-pool
```

### 1-5. Name of the volume to be used for cephfs

```shell script
$ ceph fs volume ls
[
    {
        "name": "myfs"
    }
]
```

## 2. Deploying CSI plugins with K8s

### Deploy Namespace for CSI plugins and other resources

```shell script
$ kubectl apply -f manifests/namespace.yaml
```

### Deploy ConfigMap for CSI plugins

|Parameter |Value |
|---|---|
|`clusterID` | `fsid` from the step 1-2 |
|`monitors` | `mon_host` from the step 1-2 |

```shell script
# Replace `clusterID` and `monitors`.
$ kubectl apply -f manifests/csi-config-map.yaml

$ kubectl apply -f manifests/ceph-conf.yaml
```

### Deploy Secret for CSI plugins

|Parameter |Value |
|---|---|
|`userKey` | `key` value from the step 1-3 |
|`adminKey` | `key` value from the step 1-3 |

```shell script
# rbd
# Replace `userKey`.
$ kubectl apply -f manifests/rbd/secret.yaml

# cephfs
# Replace `adminKey`.
$ kubectl apply -f manifests/cephfs/secret.yaml
```

### Deploy RBAC

```shell script
# rbd
$ kubectl apply -f manifests/rbd/csi-nodeplugin-rbac.yaml
$ kubectl apply -f manifests/rbd/csi-provisioner-rbac.yaml

# cephfs
$ kubectl apply -f manifests/cephfs/csi-nodeplugin-rbac.yaml
$ kubectl apply -f manifests/cephfs/csi-provisioner-rbac.yaml
```

### Deploy CSI plugins

```shell script
# rbd
$ kubectl apply -f manifests/rbd/csi-rbdplugin-provisioner.yaml
$ kubectl apply -f manifests/rbd/csi-rbdplugin.yaml

# verify deployment
$ kubectl get pod -n ceph-csi
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
ceph-csi      csi-rbdplugin-fvh8j                             3/3     Running   0          28s
ceph-csi      csi-rbdplugin-provisioner-7646649999-4k8fz      6/6     Running   0          23s
ceph-csi      csi-rbdplugin-provisioner-7646649999-sc92b      6/6     Running   0          23s
ceph-csi      csi-rbdplugin-provisioner-7646649999-x2wg5      6/6     Running   0          23s

# cephfs
$ kubectl apply -f manifests/cephfs/csi-cephfsplugin-provisioner.yaml
$ kubectl apply -f manifests/cephfs/csi-cephfsplugin.yaml

# verify deployment
$ kubectl get pod -n ceph-csi
NAMESPACE     NAME                                            READY   STATUS    RESTARTS   AGE
ceph-csi      csi-cephfsplugin-k5mh5                          3/3     Running   0          51s
ceph-csi      csi-cephfsplugin-provisioner-66458c7db6-2sm8f   6/6     Running   0          43s
ceph-csi      csi-cephfsplugin-provisioner-66458c7db6-mcxms   6/6     Running   0          44s
ceph-csi      csi-cephfsplugin-provisioner-66458c7db6-swpqv   6/6     Running   0          43s
```

## 3. Verifying CSI plugins

### Deploy StorageClass

|Parameter |Value |
|---|---|
|`clusterID` | `fsid` from the step 1-2 |
|`pool` | rbd pool name from the step 1-4 |
|`fsName` | cephfs volume name from the step 1-5 |

```shell script
# rbd
# Replace `clusterID` and `pool`.
$ kubectl apply -f manifests/rbd/storageclass.yaml

$ kubectl get sc
NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-rbd-sc           rbd.csi.ceph.com           Delete          Immediate           true                   17s

# cephfs
# Replace `clusterID` and `fsName`.
$ kubectl apply -f manifests/cephfs/storageclass.yaml

$ kubectl get sc
NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
csi-cephfs-sc        cephfs.csi.ceph.com        Delete          Immediate           true                   2s
```

### Deploy Pvc

```shell script
# rbd
$ kubectl apply -f manifests/rbd/pvc.yaml

$ kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
rbd-pvc          Bound    pvc-178a7e5b-1d64-485a-95bd-6980e9e0e793   1Gi        RWO            csi-rbd-sc      18m

# cephfs
$ kubectl apply -f manifests/cephfs/pvc.yaml

$ kubectl get pvc
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS    AGE
csi-cephfs-pvc   Bound    pvc-02748c76-f985-4161-a191-b7ff4c030509   1Gi        RWX            csi-cephfs-sc   22m
```

### Deploy Pod

```shell script
# rbd
$ kubectl apply -f manifests/rbd/pod.yaml

$ kubectl get pod
NAME                  READY   STATUS    RESTARTS   AGE
busybox               1/1     Running   0          30s

# cephfs
$ kubectl apply -f manifests/cephfs/pod.yaml

$ kubectl get pod
NAME                  READY   STATUS    RESTARTS   AGE
csi-cephfs-demo-pod   1/1     Running   0          25s
```
