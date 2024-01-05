#!/bin/bash

# For CentOS7 install see:
# https://github.com/radiasoft/devops/wiki/AWS#gpu-driver-install

build_image_base=radiasoft/beamsim-jupyter
build_is_public=1
# POSIT container-beamsim-jupyter
# nvidia-container-runtime needs the environment vars "OCI"
build_dockerfile_aux='ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=12.2 brand=tesla,driver>=525.60.13"'
# use previous command
build_docker_cmd=

build_as_root() {
    umask 022
    cd "$build_guest_conf"
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora37/x86_64/cuda-fedora37.repo
    build_yum install cuda-12-2
    # https://gitlab.com/nvidia/container-images/cuda/-/blob/e3ff10eab3a1424fe394899df0e0f8ca5a410f0f/dist/12.2.2/centos7/base/cuda.repo-x86_64
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
    build_yum install libcudnn8-8.9.7.29-1.cuda12.2 libcudnn8-devel-8.9.7.29-1.cuda12.2
    ldconfig
    # do after other yum operations so they have a consistent db
    rpm -e --nodeps rscode-hypre rscode-ml
}

build_as_run_user() {
    umask 022
    rpm_code_debug=1 rpm_code_install_dir=/nonexistent radia_run rpm-code hypre gpu-only
    install_repo_eval ml-python gpu
}
