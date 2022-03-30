# Toolbox Guide

Ceph-csi 버전 업데이트에 따른 yaml manifest 관리를 위한 팀 내 내부용 쉘 스크립트 입니다. `manifests` 디렉토리 내에 yaml 파일을 새로운 Ceph-csi 버전으로 업데이트 시에 필요한 작업을 자동화하여 install-hypersds 새 release가 필요할 때 사용할 수 있습니다.

## 사용법

0. `manifests` 디렉토리가 존재하는지 확인합니다. 
1. `Toolbox.sh`에 ceph-csi `VER`을 명시합니다.
2. 새로운 ceph-csi 버전에서 추가 및 제거된 yaml이 있는지 확인하여 `rbd_yamls`, `fs_yamls`, `common_yamls`, `example_yamls`, `test_yamls` 변수를 적절하게 업데이트 해줍니다.
  - rbd
    - [가이드](https://github.com/ceph/ceph-csi/blob/devel/docs/deploy-rbd.md)
    - [배포 yaml directory](https://github.com/ceph/ceph-csi/tree/devel/deploy/rbd/kubernetes)
    - [예제 yaml directory](https://github.com/ceph/ceph-csi/tree/devel/examples/rbd)
  - cephfs
    - [가이드](https://github.com/ceph/ceph-csi/blob/devel/docs/deploy-cephfs.md)
    - [배포 yaml directory](https://github.com/ceph/ceph-csi/tree/devel/deploy/cephfs/kubernetes)
    - [예제 yaml directory](https://github.com/ceph/ceph-csi/tree/devel/examples/cephfs)
3. yaml manifest를 다운로드 합니다.
  ```
  $ ./toolbox.sh download
  ```
4. yaml manifest에서 수동으로 업데이트가 필요한 부분을 고쳐줍니다.
  - cephfs 관련 yaml 중 namespace 명시가 빠진 리소스들 namespace 추가 해주기
  - ceph cluster 정보 업데이트가 필요한 필드들 정보 추가 해주기
  - kms 사용하지 않는 경우 해당 필드들 삭제
  - 배포 환경에 따라 provisioner replica 개수 줄이기
5. k8s에 yaml manifest를 배포하여 확인합니다.
  ```
  $ ./toolbox.sh deploy
  ```
6. k8s에서 배포된 리소스를 모두 삭제합니다.
  ```
  $ ./toolbox.sh clean
  ```

## Reference

- Inspired by [ceph-csi plugin-deploy.sh](https://github.com/ceph/ceph-csi/blob/devel/examples/rbd/plugin-deploy.sh)
- Inspired by [ceph-csi plugin-teardown.sh](https://github.com/ceph/ceph-csi/blob/devel/examples/rbd/plugin-teardown.sh)
