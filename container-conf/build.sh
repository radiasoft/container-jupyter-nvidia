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
    # Must be the same as on the host kernel
    dnf install -y https://developer.download.nvidia.com/compute/cuda/repos/fedora29/x86_64/cuda-repo-fedora29-10.1.243-1.x86_64.rpm
    dnf install -y cuda-toolkit-10-1
    dnf install -y https://developer.download.nvidia.com/compute/machine-learning/repos/rhel7/x86_64/nvidia-machine-learning-repo-rhel7-1.0.0-1.x86_64.rpm
    dnf install -y libcudnn7
    umask 022
    ln -s libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
    echo /usr/local/cuda/lib64/stubs > /etc/ld.so.conf.d/rscontainers-cuda-stubs.conf
    ldconfig
}

build_as_run_user() {
    umask 022
    pyenv global py3
    pip uninstall -y tensorflow
    pip install tensorflow-gpu
# python -c 'import tensorflow; tensorflow.config.experimental.list_physical_devices()'
}

#dnf install cuda-cusparse-dev-10-1 cuda-command-line-tools-10-1 cuda-cufft-10-1 cuda-curand-10-1 cuda-cusolver-10-1
#LD_LIBRARY_PATH=/usr/lib64/mpich/lib:/home/vagrant/.local/lib:/usr/local/cuda/lib64
#/usr/local/cuda/bin:/
#Needs bazel
#
#curl -L -O https://github.com/bazelbuild/bazel/releases/download/0.26.1/bazel-0.26.1-linux-x86_64 | \
#    install -m550 /dev/stdin ~/bin/bazel
#dnf install -y https://developer.download.nvidia.com/compute/machine-learning/repos/rhel7/x86_64/nvidia-machine-learning-repo-rhel7-1.0.0-1.x86_64.rpm
#dnf install -y libcudnn7-devel
#
#
#-rw-r-----  1 vagrant vagrant   1142 Nov 19 17:59 .tf_configure.bazelrc
#tensorflow$ cat .tf_conf*
#cat .tf_conf*
#build --action_env PYTHON_BIN_PATH="/home/vagrant/.pyenv/versions/py3/bin/python"
#build --action_env PYTHON_LIB_PATH="/home/vagrant/.pyenv/versions/py2/lib/synergia"
#build --python_path="/home/vagrant/.pyenv/versions/py3/bin/python"
#build --action_env PYTHONPATH="/home/vagrant/.pyenv/versions/py2/lib/synergia"
#build:xla --define with_xla_support=true
#build --config=xla
#build --action_env CUDA_TOOLKIT_PATH="/usr/local/cuda"
#build --action_env TF_CUDA_COMPUTE_CAPABILITIES="3.5,7.0"
#build --action_env LD_LIBRARY_PATH="/home/vagrant/.pyenv/versions/py2/lib/synergia:$/usr/lib64/mpich/lib:/usr/lib64/mpich/lib:/home/vagrant/.local/lib"
#build --action_env GCC_HOST_COMPILER_PATH="/usr/bin/gcc"
#build --config=cuda
#build:opt --copt=-march=native
#build:opt --copt=-Wno-sign-compare
#build:opt --host_copt=-march=native
#build:opt --define with_default_optimizations=true
#test --flaky_test_attempts=3
#test --test_size_filters=small,medium
#test --test_tag_filters=-benchmark-test,-no_oss,-oss_serial
#test --build_tag_filters=-benchmark-test,-no_oss
#test --test_tag_filters=-gpu
#test --build_tag_filters=-gpu
#build --action_env TF_CONFIGURE_IOS="0"
#
#
#bazel build //tensorflow/tools/pip_package:build_pip_package
#./bazel-bin/tensorflow/tools/pip_package/build_pip_package tensorflow_pkg
#pip install tensorflow_pkg/*whl
#
