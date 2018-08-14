set GIT_TAG=%1
set PY_VER=%2
set "PY_VER_S=%PY_VER:.=%"

set LOC=%CD%

if NOT EXIST %LOC%\m3 (
  powershell -command "& { (New-Object Net.WebClient).DownloadFile('https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Windows-x86_64.exe', 'm3.exe') }"
  start /wait "" m3.exe /InstallationType=JustMe /AddToPath=0 /RegisterPython=0 /NoRegistry=1 /S /D=%CD%\m3
)
set CONDA_AUTO_UPDATE_CONDA=False
%LOC%\m3\Scripts\conda install m2w64-ntldd-git -y

mkdir %LOC%\io

%LOC%\m3\Scripts\conda create -yp %LOC%\py%PY_VER_S% cmake make swig python=%PY_VER% pip boost=1.67

set PREFIX=%LOC%\py%PY_VER_S%

rmdir /s /q malmo
git clone https://github.com/Microsoft/malmo %LOC%\malmo
cd malmo
git reset --hard %GIT_TAG%
for %%f in (%LOC%\..\patches\%GIT_TAG%\*.diff) do (
  git apply %%f
)

rmdir /s /q build
mkdir build
cd build
REM Need to link zlib statically too
del %PREFIX%\Library\lib\zlib.lib %PREFIX%\Library\lib\z.lib
copy %PREFIX%\Library\lib\zlibstatic.lib %PREFIX%\Library\lib\zlib.lib
copy %PREFIX%\Library\lib\zlibstatic.lib %PREFIX%\Library\lib\z.lib
%PREFIX%\Library\bin\cmake ^
  -G"Visual Studio 14 2015 Win64" ^
  -DCMAKE_PREFIX_PATH=%PREFIX% ^
  -DCMAKE_BUILD_TYPE=Release ^
  -DBoost_USE_STATIC_LIBS=ON ^
  -DUSE_PYTHON_MODULE=python%PY_VER_S% ^
  -DUSE_PYTHON_VERSIONS=%PY_VER% ^
  -DINCLUDE_JAVA=OFF ^
  -DBUILD_DOCUMENTATION=OFF ^
  -DBUILD_MOD=OFF ^
  -DINCLUDE_CSHARP=OFF ^
  ..
%PREFIX%\Library\bin\cmake --build . --target INSTALL -- /p:Configuration=Release
%LOC%\m3\Library\mingw-w64\bin\ntldd.exe install\Python_Examples\MalmoPython.pyd
cd ..

cd scripts\python-wheel
call %LOC%\m3\Scripts\activate %LOC%\py%PY_VER_S%
cmd /c windows_wheel.bat
copy package\dist\*.whl %LOC%\io

