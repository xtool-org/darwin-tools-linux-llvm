#!/bin/sh

set -e

root="${PWD}"
stage="${root}/build/bin"
install="${root}/build/install"

rm -rf "${install}" "${stage}" output/toolset.tar.gz
mkdir -p "${install}" "${stage}" output

echo "[info] Building..."

cmake -B build/cmake -S llvm-project/llvm -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_INCLUDE_TESTS=OFF \
    -DLLVM_STATIC_LINK_CXX_STDLIB=ON \
    -DCMAKE_SKIP_INSTALL_RPATH=ON \
    -DLLVM_TARGETS_TO_BUILD="AArch64;X86" \
    -DLLVM_ENABLE_PROJECTS="lld" \
    -DCMAKE_EXE_LINKER_FLAGS=-static \
    -DCMAKE_INSTALL_PREFIX="${install}"

cmake --build build/cmake -j "$(nproc --all)" \
    -t llvm-strip \
    -t install-dsymutil \
    -t install-lld \
    -t install-llvm-libtool-darwin \
    -t install-llvm-lipo

echo "[info] Staging..."

for file in dsymutil lld llvm-libtool-darwin llvm-lipo; do
    build/cmake/bin/llvm-strip "${install}/bin/${file}"
    cp -aL "${install}/bin/${file}" "${stage}/"
done
mv "${stage}/lld" "${stage}/ld64.lld"
# swift-build assumes we have an Apple-flavored librarian for Apple platforms
# (https://github.com/swiftlang/swift-build/blob/b2433e74e/Sources/SWBCore/SpecImplementations/Tools/LinkerTools.swift#L1735)
# but allows us to override this assumption if we explicitly provide the name llvm-lib (look a few lines above in that file)
mv "${stage}/llvm-libtool-darwin" "${stage}/llvm-lib"
mv "${stage}/llvm-lipo" "${stage}/lipo"

echo "[info] Packaging..."

tar czvf output/toolset.tar.gz -C build bin
