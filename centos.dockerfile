
FROM daocloud.io/library/centos:centos6.6
MAINTAINER xiaohong.chen <xiaohong.chen@cootek.cn>


LABEL Description="This image is used for build, support c++"
#sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/'
RUN  yum update -y \
	&&  yum install -y tar bzip2  bzip2-devel git cmake  wget \
		flex byacc byacc-devel bison bison-devel mysql-devel \
		mysql-libs unixODBC openssh-clients freetds unixODBC-devel \
		libtool openssl-devel gmp-devel libpcap-devel gcc gcc-c++ \
	&& wget https://mirrors.ustc.edu.cn/gnu/bison/bison-3.0.tar.gz \
	&& tar zxvf bison-3.0.tar.gz && cd bison-3.0 && ./configure --prefix=/usr/local && make && make install && cd .. && rm bison-3.0  -rf  && rm bison-3.0.tar.gz

ENV GCCVersion=4.9.2
RUN wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-4.9.2/gcc-${GCCVersion}.tar.bz2 \
    &&  tar -jxvf  gcc-${GCCVersion}.tar.bz2 \
    && cd gcc-${GCCVersion} && ./contrib/download_prerequisites && cd .. \
    && mkdir gcc-build-${GCCVersion} && cd  gcc-build-${GCCVersion} \
    && ../gcc-${GCCVersion}/configure --enable-checking=release --enable-languages=c,c++ --disable-multilib --with-dwarf2  --build=x86_64-redhat-linux \
    && make  \
    && make install \
    && update-alternatives --install /usr/bin/gcc gcc /usr/local/bin/i686-pc-linux-gnu-gcc 40 \
    && gcc -v \
    && cd .. && rm gcc-build-${GCCVersion} -rf && rm gcc-${GCCVersion} -rf  && rm gcc-${GCCVersion}.tar.bz2 

ENV CC=/usr/local/bin/gcc
ENV CXX=/usr/local/bin/g++ 
	
	



