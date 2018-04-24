FROM daocloud.io/centos_cpp:6.6

LABEL MAINTAINER="xiaohong.chen <xiaohong.chen@cootek.cn>"

LABEL Description="This image is used for build, support c++"

COPY * /opt/cpp_third-part/server/tarfile/
COPY conf/* /opt/cpp_third-part/server/tarfile/conf/
COPY patch/* /opt/cpp_third-part/server/tarfile/patch/

RUN /opt/cpp_third-part/server/tarfile/automake_tar.sh \
    &&  rpm -ivh /opt/cpp_third-part/server/tarfile/odb-2.3.0-1.x86_64.rpm
