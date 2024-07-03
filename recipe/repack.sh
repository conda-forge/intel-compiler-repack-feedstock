#!/bin/bash
set -ex

# for subpackages, we have named our extracted locations according to the subpackage name
#    That's what this $PKG_NAME is doing - picking the right subfolder to rsync

src="${SRC_DIR}/${PKG_NAME}"

# TODO: remove once fixed in the upstream
# It looks like it was resolved in 2024.2.0, but exist in 2024.1.2. Let's keep
# it till 2025, in case it repeats.
if [[ "$PKG_NAME" == "dpcpp_impl_linux-64" ]]; then
  # Move intel specific headers files from the global include directory to
  # allow other compilers work in the same environment.
  find ${src}/include -maxdepth 1 -type f -exec mv {} ${src}/opt/compiler/include \;
  # Move it to the sycl directory to much structure with /opt/intel/include
  mv ${src}/lib/clang/18/include/CL ${src}/include/sycl/CL || true
fi

# TODO: remove once fixed in the upstream
# It looks like it was resolved in 2024.2.0, but exist in 2024.1.2. Let's keep
# it till 2025, in case it repeats.
if [[ "$PKG_NAME" == "intel-cmplr-lib-rt" ]]; then
  # One of the libraries is referencing to libur_loader.so which is part of 
  # intel-sycl-rt that results in cyclic dependency. This change breaks cyclic
  # dependency and organize the libraries in a tree way dependency. 
  # intel-cmplr-lib-rt is in dependency of intel-sycl-rt, so no changes to
  # downstream projects required.
  mv ${SRC_DIR}/intel-sycl-rt/lib/libur_loader.so* ${src}/lib/ || true
fi

cp -av "${src}"/* "${PREFIX}/"

# replace old info folder with our new regenerated one
rm -rf "${PREFIX}/info"

if [[ "$PKG_NAME" == "intel-fortran-rt" && "$target_platform" == "linux-"* ]]; then
  for f in "libicaf.so" "libifcoremt.so.5" "libifcore.so.5" "libifport.so.5"; do
    # Remove RUNPATH and keep only RPATH
    patchelf --set-rpath '$ORIGIN' --force-rpath ${PREFIX}/lib/$f
  done
fi

if [[ "$PKG_NAME" == "dpcpp_impl_linux-64" ]]; then
  # Not sure why these libraries are there, but seems to be unused.
  rm -f $PREFIX/lib/libffi.so*
  HOST=x86_64-conda-linux-gnu
  echo "--gcc-toolchain=${PREFIX} --sysroot=${PREFIX}/${HOST}/sysroot -target ${HOST}" > ${PREFIX}/bin/$HOST-icpx.cfg
  echo "--gcc-toolchain=${PREFIX} --sysroot=${PREFIX}/${HOST}/sysroot -target ${HOST}" > ${PREFIX}/bin/$HOST-icx.cfg
fi
