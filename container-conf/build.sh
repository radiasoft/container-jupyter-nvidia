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
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"'
# use previous command
build_docker_cmd=

build_as_root() {
    umask 022
    cd "$build_guest_conf"
    dnf config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/fedora29/x86_64/cuda-fedora29.repo
    build_yum install cuda-toolkit-10-1
    cat > /etc/ld.so.conf.d/rs-cuda.conf <<'EOF'
/usr/local/cuda/extras/CUPTI/lib64
EOF
    # https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/centos7/10.1/runtime/cudnn7/Dockerfile
    # modified to use 10.0
    build_curl -O http://developer.download.nvidia.com/compute/redist/cudnn/v7.6.5/cudnn-10.1-linux-x64-v7.6.5.32.tgz
    tar --no-same-owner -xzf cudnn-10.1-linux-x64-v7.6.5.32.tgz -C /usr/local --wildcards 'cuda/lib64/libcudnn.so.*'
    ldconfig
}

build_as_run_user() {
    umask 022
    pip uninstall -y tensorflow keras
    pip install tensorflow keras
}
