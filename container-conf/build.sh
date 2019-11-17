#!/bin/bash
build_image_base=radiasoft/beamsim-jupyter
build_is_public=1
# POSIT container-beamsim-jupyter
build_dockerfile_aux="USER $build_run_user"
beamsim_jupyter_boot_dir=$build_run_user_home/.radia-run
beamsim_jupyter_tini_file=$beamsim_jupyter_boot_dir/tini
beamsim_jupyter_radia_run_boot=$beamsim_jupyter_boot_dir/start
build_docker_cmd='["'"$beamsim_jupyter_tini_file"'", "--", "'"$beamsim_jupyter_radia_run_boot"'"]'

build_as_root() {
    rpm -i https://developer.download.nvidia.com/compute/cuda/repos/fedora29/x86_64/cuda-repo-fedora29-10.1.243-1.x86_64.rpm
    dnf install -y kmodtool kernel-devel cuda-drivers
}
