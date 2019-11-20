#!/bin/bash
build_image_base=radiasoft/beamsim-jupyter
build_is_public=1
# POSIT container-beamsim-jupyter
# nvidia-container-runtime needs the environment vars "OCI"
build_dockerfile_aux="USER $build_run_user"'
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=410,driver<411"'
beamsim_jupyter_boot_dir=$build_run_user_home/.radia-run
beamsim_jupyter_tini_file=$beamsim_jupyter_boot_dir/tini
beamsim_jupyter_radia_run_boot=$beamsim_jupyter_boot_dir/start
build_docker_cmd='["'"$beamsim_jupyter_tini_file"'", "--", "'"$beamsim_jupyter_radia_run_boot"'"]'

build_as_root() {
    # CUDA 10.1.243 be the same as on the host kernel
    umask 022
    cd "$build_guest_conf"
    build_curl -o cuda.run https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux
    # Error: unsupported compiler: 8.3.1. Use --override to override this check.
    sh cuda.run --silent --toolkit --override
    rm -f cuda.run
    # Remove to avoid error:
    # tensorflow/stream_executor/cuda/cuda_diagnostics.cc:200] libcuda reported version is: Not found: was unable to find libcuda.so DSO loaded into this program
    # the nvidia-container-runtime puts a libcuda.so in /lib64, and we want to use that
    rm -f /usr/local/cuda/lib64/stubs/libcuda.so
    # CPUTI might as well be here, not in LD_LIBRARY_PATH
    cat > rs-cuda.conf <<'EOF'
/usr/local/cuda/lib64/stubs
/usr/local/cuda/lib64
/usr/local/cuda/extras/CUPTI/lib64
EOF
    # https://gitlab.com/nvidia/container-images/cuda/blob/master/dist/centos7/10.1/runtime/cudnn7/Dockerfile
    # modified to use 10.0
    build_curl -O http://developer.download.nvidia.com/compute/redist/cudnn/v7.6.4/cudnn-10.0-linux-x64-v7.6.4.38.tgz
    tar --no-same-owner -xzf cudnn-10.0-linux-x64-v7.6.4.38.tgz -C /usr/local --wildcards 'cuda/lib64/libcudnn.so.*'
    ldconfig
}

build_as_run_user() {
    umask 022
    pyenv global py3
    pip uninstall -y tensorflow
    pip install tensorflow-gpu
}
