#!/bin/bash
build_image_base=radiasoft/beamsim-jupyter
build_is_public=1
build_dockerfile_aux="USER $build_run_user"

build_as_root() {
    rpm -i https://developer.download.nvidia.com/compute/cuda/repos/fedora29/x86_64/cuda-repo-fedora29-10.1.243-1.x86_64.rpm
    dnf install -y kmodtool kernel-devel cuda-drivers
}
