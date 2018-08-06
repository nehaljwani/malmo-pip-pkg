# Linux

  - Build the docker image
    ```sh
    $ sudo docker build . -t malmo_wheel
    ```
  - Build the wheel
    ```sh
    $ export MALMO_GIT_TAG=0.35.6
    $ export PYTHON_VERSION=3.7
    $ sudo docker run --rm -v $PWD/io:/io malmo_wheel $MALMO_GIT_TAG $PYTHON_VERSION
    $ ls io/
    malmo-0.35.6.0-cp37-cp37m-manylinux1_x86_64.whl
    ```
