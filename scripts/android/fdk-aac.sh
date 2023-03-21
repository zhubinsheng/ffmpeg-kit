#!/bin/bash

# ALWAYS CLEAN THE PREVIOUS BUILD
make distclean 2>/dev/null 1>/dev/null

# REGENERATE BUILD FILES IF NECESSARY OR REQUESTED
if [[ ! -f "${BASEDIR}"/src/"${LIB_NAME}"/configure ]] || [[ ${RECONF_gmp} -eq 1 ]]; then
  autoreconf_library "${LIB_NAME}" 1>>"${BASEDIR}"/build.log 2>&1 || return 1
fi

#--disable-shared 不能禁用动态链接库ffmpeg需要动态库
AAC_CONFIGURE_FLAGS="--enable-static  --enable-shared --target=android"
echo "TOOLCHAINS_PREFIX:$TOOLCHAINS_PREFIX"

echo "LIB_INSTALL_PREFIX:${LIB_INSTALL_PREFIX}"
echo "ANDROID_SYSROOT:${ANDROID_SYSROOT}"
echo "HOST:${HOST}"

./configure \
  --prefix="${LIB_INSTALL_PREFIX}" \
  --with-sysroot="${ANDROID_SYSROOT}" \
  $AAC_CONFIGURE_FLAGS \
  --host="${HOST}" || return 1

make -j$(get_cpu_count) || return 1

echo "Android aac bulid success!"

make install || return 1

# CREATE PACKAGE CONFIG MANUALLY
# MANUALLY COPY PKG-CONFIG FILES
cp fdk-aac.pc "${INSTALL_PKG_CONFIG_DIR}" || return 1
