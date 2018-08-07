#!/usr/bin/env bash

set -x

GIT_TAG=$1
PY_VER=$2
PY_VER_S=${2/./}

LOC=$PWD

MINICONDA=Miniconda3-4.5.4-MacOSX-x86_64.sh
curl -LO https://repo.anaconda.com/miniconda/$MINICONDA
bash $MINICONDA -bfp $LOC/m3
echo -e "channels:\n  - conda-forge" > $LOC/m3/.condarc && \

mkdir -p $LOC/io

$LOC/m3/bin/conda create -yp $LOC/py35 cmake make swig python=3.5 boost=1.66 boost-cpp=1.66 -c malmo/label/macOS10.9
$LOC/m3/bin/conda create -yp $LOC/py36 cmake make swig python=3.6 boost=1.66 boost-cpp=1.66 -c malmo/label/macOS10.9
$LOC/m3/bin/conda create -yp $LOC/py37 cmake make swig python=3.7 boost=1.67 boost-cpp=1.67 -c malmo/label/macOS10.9
ln $LOC/py37/lib/libboost_python37.a $LOC/py37/lib/libboost_python3.a

PREFIX=$PWD/py$PY_VER_S

git clone https://github.com/Microsoft/malmo ./malmo
cd malmo
git checkout $1

rm -fr build
mkdir build
cd build
rm -f $PREFIX/lib/libz.dylib # Need static lib only
export CXXFLAGS="-mmacosx-version-min=10.9"
$PREFIX/bin/cmake \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DBoost_USE_STATIC_LIBS=ON \
  -DCMAKE_INSTALL_RPATH='$ORIGIN:$ORIGIN/../../../../lib' \
  -DUSE_PYTHON_VERSIONS=$PY_VER \
  -DMACOS_USE_PYTHON_MODULE="python3" \
  -DINCLUDE_JAVA=OFF \
  -DBUILD_DOCUMENTATION=OFF \
  -DBUILD_MOD=OFF \
  ..
make install
otool -L install/Python_Examples/MalmoPython.so
cd ..

cd scripts/python-wheel
sed -i.bak -e '/^twine/d' -e '/^pip3/d' -e '/^rm/d' linux_macos_wheel.sh
source $LOC/m3/bin/activate $LOC/py$PY_VER_S
bash linux_macos_wheel.sh
cp package/dist/*.whl $LOC/io
