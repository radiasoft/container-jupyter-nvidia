#!/bin/bash

# For CentOS7 install see:
# https://github.com/radiasoft/devops/wiki/AWS#gpu-driver-install

build_image_base=radiasoft/beamsim-jupyter
build_is_public=1
# POSIT container-beamsim-jupyter
# nvidia-container-runtime needs the environment vars "OCI"
build_dockerfile_aux="USER $build_run_user"'
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=11.1 brand=tesla,driver>=410"'
# use previous command
build_docker_cmd=

build_as_root() {
    umask 022
    cd "$build_guest_conf"
    dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/fedora32/x86_64/cuda-fedora32.repo
    build_yum install cuda-toolkit-11-1
    # https://gitlab.com/nvidia/container-images/cuda/-/blob/master/dist/11.1.1/centos7-x86_64/runtime/cudnn8/Dockerfile
    dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo
    build_yum install libcudnn8-8.0.5.39-1.cuda11.1.x86_64
    ldconfig
}

build_as_run_user() {
    umask 022
    pip uninstall -y tensorflow keras
    pip install tensorflow keras
    rpm_code_debug=1 rpm_code_install_dir=/nonexistent radia_run rpm-code elegant gpu-only
}
