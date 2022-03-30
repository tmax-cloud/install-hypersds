#!/bin/bash

VER=v5.0.1

local_base="manifests"
cephcsi_base="../ceph-csi/manifests"
remote_base="https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/${VER}"

crd_yamls=(kustomization snapshot.storage.k8s.io_volumesnapshotclasses snapshot.storage.k8s.io_volumesnapshotcontents snapshot.storage.k8s.io_volumesnapshots)
controller_yamls=(kustomization rbac-snapshot-controller setup-snapshot-controller)
test_yamls=(snapshotclass snapshot pvc-restore)

function print_help() {
    echo " $0 [command]
Yaml Manifest Toolbox

Available Commands:
  download
  deploy
  clean
" >&2
}

function update(){
    pushd "${local_base}" >/dev/null || exit 1
    
    pushd "crd" >/dev/null || exit 1
    for obj in "${crd_yamls[@]}"; do
    	wget -qN "${remote_base}/client/config/crd/${obj}.yaml"
    done
    popd >/dev/null || exit 1
    
    pushd "controller" >/dev/null || exit 1
    for obj in "${controller_yamls[@]}"; do
    	wget -qN "${remote_base}/deploy/kubernetes/snapshot-controller/${obj}.yaml"
    done
    popd >/dev/null || exit 1
}

function install(){
    pushd "${local_base}" >/dev/null || exit 1
    kubectl apply -k crd
    kubectl apply -k controller -n kube-system
    popd >/dev/null || exit 1

    pushd "${cephcsi_base}" >/dev/null || exit 1
    pushd "rbd" >/dev/null || exit 1
    for obj in "${test_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1
    
    pushd "cephfs" >/dev/null || exit 1
        for obj in "${test_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1
}

function uninstall(){
    pushd "${cephcsi_base}/rbd" >/dev/null || exit 1
    for obj in "${test_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1

    pushd "${cephcsi_base}/cephfs" >/dev/null || exit 1
        for obj in "${test_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1

    pushd "${local_base}" >/dev/null || exit 1
    kubectl delete -k controller -n kube-system
    kubectl delete -k crd
    popd >/dev/null || exit 1
}

case "${1:-}" in
download)
  echo "Fetching snapshotter ${VER} yamls from github..."
  update
  ;;
deploy)
  install
  ;;
clean)
  uninstall
  ;;
*)
  print_help
  ;;
esac