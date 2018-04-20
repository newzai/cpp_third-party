1. gsoap-2.8.tar.gz
   C++ WebServie 库，gsoap++
2. boost_1_55_0.tar.gz 
   尽量少使用，能使用标准C++，就使用标准C++，尽量使用C++11，C++14的特性，而不是boost
   主要使用了ptree类（libCommon配置文件)
3.glog-0.3.3.tar.gz
  google的日志框架
4. google-perftools-1.9.1.tar.tz
   主要使用tcmalloc
5.libghttp-1.0.9.tar.gz 
   http客户端库，用于作为http客户端使用，例如PoC的群组操作等
6. libodb-2.3.0.tar.gz/libodb-mysql-2.3.0.tar.gz/libodb-sqlite-2.3.0.tar.gz
   一个跨平台和跨数据库的数据库API
   基于ORM（对象映射关系)的数据库API
   
   odb-2.3.0-1.i686.rpm/odb-2.3.0-1.x86_64.rpm
   odb编译器，用于自从生成SQL语句;
7.protobuf-2.3.0.tar.gz
  protobuf 通信协议基础库         
  
8. CAF(C++ Actor Framework ) 安装
	
	git clone https://github.com/actor-framework/actor-framework
	cd actor-framework/
	./configure --prefix=/opt/jianyu/local/ --no-compiler-check --with-log-level=TRACE --build-static-only --with-gcc=/usr/local/bin/g++ --no-qt-examples 
	make 
	make install
	