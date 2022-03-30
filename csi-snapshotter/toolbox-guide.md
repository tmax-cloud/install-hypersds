# Toolbox Guide

external-snapshotter 버전 업데이트에 따른 yaml manifest 관리를 위한 내부용 쉘 스크립트 입니다. `manifests` 디렉토리 내에 yaml 파일을 새로운 external-snapshotter 버전으로 업데이트 시에 필요한 작업을 자동화하여 install-hypersds 새 release가 필요할 때 사용할 수 있습니다.

## 사용법

0. `manifests` 디렉토리가 존재하는지 확인합니다. 
1. `Toolbox.sh`에 external-snapshotter `VER`을 명시합니다.
2. 새로운 external-snapshotter 버전에서 추가 및 제거된 yaml이 있는지 확인하여 `crd_yamls`, `controller_yamls`, `test_yamls` 변수를 적절하게 업데이트 해줍니다.
  - rbd
    - [예제 yaml directory](https://github.com/ceph/ceph-csi/tree/devel/examples/rbd)
  - cephfs
    - [예제 yaml directory](https://github.com/ceph/ceph-csi/tree/devel/examples/cephfs)
3. yaml manifest를 다운로드 합니다.
  ```
  $ ./toolbox.sh download
  ```
4. k8s에 yaml manifest를 배포하여 확인합니다.
  ```
  $ ./toolbox.sh deploy
  ```
5. k8s에서 배포된 리소스를 모두 삭제합니다.
  ```
  $ ./toolbox.sh clean
  ```
