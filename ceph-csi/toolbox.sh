#!/bin/bash

VER=v3.5.1

namespace="ceph-csi"
local_base="manifests"
remote_base="https://raw.githubusercontent.com/ceph/ceph-csi/${VER}"

rbd_yamls=(csi-provisioner-rbac csi-nodeplugin-rbac csi-rbdplugin-provisioner csi-rbdplugin)
fs_yamls=(csi-provisioner-rbac csi-nodeplugin-rbac csi-cephfsplugin-provisioner csi-cephfsplugin)
common_yamls=(namespace csi-config-map ceph-conf)
example_yamls=(storageclass snapshotclass secret pod pvc snapshot pvc-restore)
test_yamls=(storageclass secret pod pvc)

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
    wget -qN "${remote_base}/deploy/rbd/kubernetes/csi-config-map.yaml"
    wget -qN "${remote_base}/examples/ceph-conf.yaml"

    pushd "rbd" >/dev/null || exit 1
    for obj in "${rbd_yamls[@]}"; do
    	wget -qN "${remote_base}/deploy/rbd/kubernetes/${obj}.yaml"
        sed -i "s|namespace: default|namespace: ${namespace}|g" ${obj}.yaml
    done
    for obj in "${example_yamls[@]}"; do
    	wget -qN "${remote_base}/examples/rbd/${obj}.yaml"
        sed -i "s|namespace: default|namespace: ${namespace}|g" ${obj}.yaml
    done
    popd >/dev/null || exit 1

    pushd "cephfs" >/dev/null || exit 1    
    for obj in "${fs_yamls[@]}"; do
    	wget -qN "${remote_base}/deploy/cephfs/kubernetes/${obj}.yaml"
        sed -i "s|namespace: default|namespace: ${namespace}|g" ${obj}.yaml
    done
    for obj in "${example_yamls[@]}"; do
    	wget -qN "${remote_base}/examples/cephfs/${obj}.yaml"
        sed -i "s|namespace: default|namespace: ${namespace}|g" ${obj}.yaml
    done
    popd >/dev/null || exit 1
}

function install(){
    pushd "${local_base}" >/dev/null || exit 1
    for obj in "${common_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done

    pushd "rbd" >/dev/null || exit 1
    for obj in "${rbd_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done
    for obj in "${test_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1

    pushd "cephfs" >/dev/null || exit 1
    for obj in "${fs_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done
    for obj in "${test_yamls[@]}"; do
        kubectl apply -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1
}

function uninstall(){
    pushd "${local_base}" >/dev/null || exit 1
    pushd "cephfs" >/dev/null || exit 1
    for obj in "${test_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
    for obj in "${fs_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1

    pushd "rbd" >/dev/null || exit 1
    for obj in "${test_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
    for obj in "${rbd_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
    popd >/dev/null || exit 1

    for obj in "${common_yamls[@]}"; do
        kubectl delete -f "./${obj}.yaml"
    done
}

case "${1:-}" in
download)
  echo "Fetching CSI ${VER} yamls from github..."
  update
  echo "Before deploy CSI manually update yamls: 
    1) add ceph-csi namespace on cephfs yamls
    2) add ceph cluster information
    3) remove/update kms information
    4) modify provisioner replica number"
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
