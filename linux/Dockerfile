FROM centos:6

ENV MINICONDA Miniconda3-4.5.4-Linux-x86_64.sh

RUN curl -L http://people.centos.org/tru/devtools-2/devtools-2.repo -o /etc/yum.repos.d/devtools-2.repo && \
    yum install bzip2 tar git devtoolset-2-gcc devtoolset-2-binutils devtoolset-2-gcc-c++ -y && \
    yum clean all

RUN curl -LO https://repo.anaconda.com/miniconda/$MINICONDA && \
    bash $MINICONDA -bp /m3 && \
    echo -e "channels:\n  - conda-forge" > /m3/.condarc && \
    rm -fr /m3/pkgs && rm -f $MINICONDA

RUN /m3/bin/conda create -yp /py35 cmake make swig python=3.5 boost=1.66 boost-cpp=1.66 -c malmo/label/centos6 && \
    /m3/bin/conda create -yp /py36 cmake make swig python=3.6 boost=1.66 boost-cpp=1.66 -c malmo/label/centos6 && \
    /m3/bin/conda create -yp /py37 cmake make swig python=3.7 boost=1.67 boost-cpp=1.67 -c malmo/label/centos6 && \
    ln -s /py37/lib/libboost_python37.a /py37/lib/libboost_python3.a && \
    rm -fr /m3/pkgs

ENV PATH $PATH:/opt/rh/devtoolset-2/root/usr/bin

COPY build_malmo_wheel.sh /

ENTRYPOINT ["/build_malmo_wheel.sh"]
