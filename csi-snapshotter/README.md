# Install Snapshot Controller

This is a guide for deploying snapshot controller using [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter).

Min K8s version is 1.20. The snapshot controller version used in this guide is v5.0.1.

## Before you begin

Install CSI provisioner through [Connect Ceph to K8s](../ceph-csi/README.md).

## Deploy CRDs

```shell script
$ kubectl apply -k manifests/crd

# verify deployment
$ kubectl get crd
NAME                                                  CREATED AT
...
volumesnapshotclasses.snapshot.storage.k8s.io         2021-10-01T15:29:58Z
volumesnapshotcontents.snapshot.storage.k8s.io        2021-10-01T15:29:58Z
volumesnapshots.snapshot.storage.k8s.io               2021-10-01T15:29:58Z
```

## Deploy Snapshot Controller

```shell script
$ kubectl apply -k manifests/controller -n kube-system

# verify deployment
$ kubectl get pod -A
NAMESPACE     NAME                                            READY   STATUS              RESTARTS   AGE
...
kube-system   snapshot-controller-9f68fdd9-k4lv9              1/1     Running             1          103m
kube-system   snapshot-controller-9f68fdd9-p4qx6              1/1     Running             0          103m
```

## Deploy VolumeSnapshotClass

- Replace `clusterID` with `fsid` in [ceph-conf](#1-2-ceph-cluster-fsid-and-monitor-list)

```shell script
# rbd
$ kubectl apply -f ../ceph-csi/manifests/rbd/snapshotclass.yaml

# verify deployment
$ kubectl get volumesnapshotclass
NAME                   DRIVER             DELETIONPOLICY   AGE
csi-rbd-snapclass      rbd.csi.ceph.com   Delete           3s

# cephfs
$ kubectl apply -f ../ceph-csi/manifests/cephfs/snapshotclass.yaml

# verify deployment
$ kubectl get volumesnapshotclass
NAME                      DRIVER                DELETIONPOLICY   AGE
csi-cephfs-snapclass      cephfs.csi.ceph.com   Delete           2s
```

## Create snapshot

- Replace `persistentVolumeClaimName` with the name of the pvc you want to create snapshot

```shell script
# rbd
$ kubectl apply -f ../ceph-csi/manifests/rbd/snapshot.yaml

# cephfs
$ kubectl apply -f ../ceph-csi/manifests/cephfs/snapshot.yaml
```

## Create new pvc from snapshot

- Change the spec of pvc to the desired value

```shell script
# rbd
$ kubectl apply -f ../ceph-csi/manifests/rbd/pvc-restore.yaml

# cephfs
$ kubectl apply -f ../ceph-csi/manifests/cephfs/pvc-restore.yaml
```
