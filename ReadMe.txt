1. gsoap-2.8.tar.gz
   C++ WebServie �⣬gsoap++
2. boost_1_55_0.tar.gz 
   ������ʹ�ã���ʹ�ñ�׼C++����ʹ�ñ�׼C++������ʹ��C++11��C++14�����ԣ�������boost
   ��Ҫʹ����ptree�ࣨlibCommon�����ļ�)
3.glog-0.3.3.tar.gz
  google����־���
4. google-perftools-1.9.1.tar.tz
   ��Ҫʹ��tcmalloc
5.libghttp-1.0.9.tar.gz 
   http�ͻ��˿⣬������Ϊhttp�ͻ���ʹ�ã�����PoC��Ⱥ�������
6. libodb-2.3.0.tar.gz/libodb-mysql-2.3.0.tar.gz/libodb-sqlite-2.3.0.tar.gz
   һ����ƽ̨�Ϳ����ݿ�����ݿ�API
   ����ORM������ӳ���ϵ)�����ݿ�API
   
   odb-2.3.0-1.i686.rpm/odb-2.3.0-1.x86_64.rpm
   odb�������������Դ�����SQL���;
7.protobuf-2.3.0.tar.gz
  protobuf ͨ��Э�������         
  
8. CAF(C++ Actor Framework ) ��װ
	
	git clone https://github.com/actor-framework/actor-framework
	cd actor-framework/
	./configure --prefix=/opt/jianyu/local/ --no-compiler-check --with-log-level=TRACE --build-static-only --with-gcc=/usr/local/bin/g++ --no-qt-examples 
	make 
	make install
	