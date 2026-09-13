#!/bin/bash
#
# Minimal GPU jupyter image: jupyterlab and torch. Compatible invocation
# with beamsim-jupyter.
#
build_image_base=radiasoft/fedora
build_is_public=1
# nvidia-container-runtime reads this from the image; without it the default
# is utility, which gets nvidia-smi but not CUDA.
build_dockerfile_aux='ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility'
build_docker_cmd=$build_run_user_home/.radia-run/start

declare -a _jupyter_nvidia_codes=(
    common
    warpx-nvidia
)
# CUDA 13 dropped sm_70 (Volta) codegen, and fedora41 is the newest NVIDIA repo
# shipping CUDA 12.
_jupyter_nvidia_cuda_repo=https://developer.download.nvidia.com/compute/cuda/repos/fedora41/x86_64/cuda-fedora41.repo

# What the warpx and amrex libraries link against. torch's wheels vendor their
# own copies, which are not on the loader's path and track torch's cuda.
declare -a _jupyter_nvidia_cuda_rpms=(
    libcurand-12-9
    libcusparse-12-9
    libnvjitlink-12-9
)
declare -a _jupyter_nvidia_rpms=(
    gnuplot-minimal
    # Needed to export notebooks https://github.com/radiasoft/devops/issues/188
    pandoc
    vim-enhanced
)
jupyterlab_basic_rpmfusion=1

# 2.11 drops sm_70 from the cu128 wheels, so this cannot move past 2.10.
_jupyter_nvidia_torch_version=2.10.0

_jupyter_nvidia_torch() {
    install_pip_install --index-url https://download.pytorch.org/whl/cu128 \
        "torch==$_jupyter_nvidia_torch_version"
}

build_as_root() {
    install_yum_install "${_jupyter_nvidia_rpms[@]}"
    install_yum_add_repo "$_jupyter_nvidia_cuda_repo"
    install_yum_install "${_jupyter_nvidia_cuda_rpms[@]}"
    install_repo_eval jupyterlab-basic as_root
}

build_as_run_user() {
    install_repo_eval beamsim-codes "${_jupyter_nvidia_codes[@]}"
    # rscode-common installs pyenv, which is not on PATH until bashrc is reread
    install_source_bashrc
    install_repo_eval jupyterlab-basic as_run_user
    _jupyter_nvidia_torch
}
