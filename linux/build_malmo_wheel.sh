#!/usr/bin/env bash
set -x

GIT_TAG=$1
PY_VER=$2
PY_VER_S=${2/./}

git clone https://github.com/Microsoft/malmo /malmo && cd $_
git checkout $1

[[ -d /io/patches/$1 ]] && git am /io/patches/$1/*.patch

mkdir build && cd $_
PREFIX=/py$PY_VER_S
rm -f $PREFIX/lib/libz.so # Need static lib only
$PREFIX/bin/cmake \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DBoost_USE_STATIC_LIBS=ON \
  -DCMAKE_INSTALL_RPATH='$ORIGIN:$ORIGIN/../../../../lib' \
  -DUSE_PYTHON_VERSIONS=$PY_VER \
  -DINCLUDE_JAVA=OFF \
  -DBUILD_DOCUMENTATION=OFF \
  -DBUILD_MOD=OFF \
  ..
make VERBOSE=1
make install
objdump -x install/Python_Examples/MalmoPython.so | grep NEEDED
cd ..

cd scripts/python-wheel
sed -i -e '/^twine/d' -e '/^pip3/d' -e '/^rm/d' linux_macos_wheel.sh
source /m3/bin/activate /py$PY_VER_S
bash linux_macos_wheel.sh manylinux1_x86_64
cp package/dist/*.whl /io/
