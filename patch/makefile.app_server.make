ifeq ($(APP_DIR),)
	APP_DIR=..
endif

ifeq ($(COMMON_DIR),)
	COMMON_DIR=..
endif

ifeq ($(CPP_VERSION),)
        CPP_VERSION=c++1y
endif

ifeq ($(ARCH),)
	ARCH=32
endif

LOCAL_DIR=${APP_DIR}/local
INCLUDE_DIR=${LOCAL_DIR}/include
BOOST_LIBS_DIR=${APP_DIR}/tarfile/boost_1_55_0
LIB_DIR=${LOCAL_DIR}/lib
ODB=odb
PROTOC=${LOCAL_DIR}/bin/protoc
STD_LIBS=-L/lib -L/lib64 -L/usr/lib -L/usr/lib64 -L/usr/lib/mysql -L/usr/lib64/mysql


#system libs
libs= -ldl -lrt  -lpthread
libs += ${COMMON_DIR}/libcommon/libcommon.a
#boost libs
#libs= -lboost_system -lboost_thread

#google libs
libs+= -lglog -lprotobuf
libs+= -lghttp

#database libs
libs+= -lodb -lodb-sqlite -lsqlite3 -lodb-mysql -lmysqlclient_r

libs+= -lgsoap++
libs+=  -lssl -lcrypto -lz

link_type = -static-libgcc -static-libstdc++

static_libs= -ldl -lrt -lpthread
static_libs+= ${COMMON_DIR}/libcommon/libcommon.a
#static_libs+= $(LIB_DIR)/libboost_system.a  $(LIB_DIR)/libboost_thread.a
static_libs+= $(LIB_DIR)/libglog.a $(LIB_DIR)/libprotobuf.a
static_libs+= $(LIB_DIR)/libghttp.a
static_libs+= $(LIB_DIR)/libodb.a 
#static_libs+= $(LIB_DIR)/libodb-sqlite.a $(LIB_DIR)/libsqlite3.a 
static_libs+= $(LIB_DIR)/libodb-mysql.a 
ifeq ($(ARCH),32)
static_libs+= /usr/lib/mysql/libmysqlclient_r.a
else
static_libs+= -lmysqlclient_r
endif
#static_libst+= /usr/lib/mysql/libmysqlclient_r.a
static_libs+= $(LIB_DIR)/libgsoap++.a
static_libs += -lssl -lcrypto -lz
static_libs+= $(LIB_DIR)/libtcmalloc_minimal.a

INCLUDE = -I. -I./model -I${COMMON_DIR}/libcommon -I./adc  -I./proto_gen_src -I./odb_src -I./bnfauto -I./service -I./poc_service -I./gis -I./lbs -I${INCLUDE_DIR} -I${BOOST_LIBS_DIR}
flags= -g -gdwarf-2 -rdynamic  -Wuninitialized  ${INCLUDE}
odbflags =-DLINUX  ${INCLUDE}
flags+= -DSQLITE_ENABLE_UNLOCK_NOTIFY -DLIBODB_SQLITE_HAVE_UNLOCK_NOTIFY -DAPP_DB_TYPE_MYSQL
flags+=  -DLINUX -DBOOST_ALL_NO_LIB  -DASIO_STANDALONE -DASIO_HAS_STD_CHRONO -DASIO_HAS_STD_SYSTEM_ERROR 
#flags+= -fkeep-inline-functions
flags+= -fpermissive 
flags+= -DENABLE_MYSQL
#flags+= -DENABLE_SQLITE
ifeq ($(CPP_VERSION),c++1y)
        flags+=-DCPLUSPLUS14
endif

SRCS = $(wildcard *.cxx)
#SRCS += $(wildcard common/*.cxx)
SRCS += $(wildcard bnfauto/*.cxx)
SRCS += $(wildcard odb_src/*.cxx)
SRCS += $(wildcard service/*.cxx)
SRCS += $(wildcard poc_service/*.cxx)
SRCS += $(wildcard model/*.cxx)
SRCS += $(wildcard psc_process/*.cxx)
#SRCS += $(wildcard process/*.cxx)
#SRCS +=$(wildcard stg/*.cxx)
SRCS += $(wildcard gis/*.cxx)
SRCS += $(wildcard lbs/*.cxx)

CPP_SRCS = $(wildcard adc/*.cpp)

CC_SRCS =$(wildcard proto_gen_src/*.cc)
UTF8_SRCS= $(SRCS:%.cxx=%.utf8.cpp)
OBJS = $(UTF8_SRCS:%.utf8.cpp=%.o)

CPP_OBJS = $(CPP_SRCS:%.cpp=%.o)
CC_OBJS = $(CC_SRCS:%.cc=%.o)

DEPS =$(OBJS:%.o=%.d)
CPP_DEPS=$(CPP_OBJS:%.o=%.d)
CC_DEPS=$(CC_OBJS:%.o=%.d)

 
BNF_TOOL=java -classpath ".:lib/scala-library.jar:lib/args4j-2.0.21.jar" cn.newzai.parser.Main
BNF_PARAMS= -dir . -ca -ccc -cdc  -cpp2proto  -cget -cset  -inline -proto -proto2cpp -spns std::tr1:: -system linux -file
BNF_PARAMS_NOT_GET_SET = -dir . -ca -ccc -cdc -cpp2proto   -inline -proto -proto2cpp -spns std::tr1:: -system linux -file

target :init app_static  app_shared

	

app_shared : $(CC_OBJS) $(OBJS) $(CPP_OBJS)
	g++ -std=$(CPP_VERSION) $(OBJS) $(CC_OBJS) $(CPP_OBJS) -L${LIB_DIR} ${STD_LIBS} ${link_type} ${libs}   -o $@
app_static : $(CC_OBJS) $(OBJS) $(CPP_OBJS)
	g++ -std=$(CPP_VERSION) $(OBJS) $(CC_OBJS) $(CPP_OBJS) -L${LIB_DIR} ${STD_LIBS} ${link_type} ${static_libs}  -o $@

app_monitor : monitor/app_monitor.cxx
	g++ monitor/app_monitor.cxx ${APP_DIR}/libcommon/libcommon.a -o app_monitor -std=c++11 ${flags}

include $(DEPS)
include $(CC_DEPS)

$(UTF8_SRCS): %.utf8.cpp : %.cxx
	cp $< $@ -rf;\
	iconv -f gbk -t utf8 $< -o $@

$(OBJS): %.o : %.utf8.cpp   %.d
	g++ -o $@ -std=$(CPP_VERSION) -c $<  ${flags}

$(CC_OBJS): %.o : %.cc  %.d
	g++ -o $@ -std=$(CPP_VERSION) -c $< ${flags}

$(CPP_OBJS): %.o : %.cpp %.d
	g++ -o $@ -std=$(CPP_VERSION) -c $< ${flags}

init:
	mkdir -p proto_gen_src; mkdir -p odb_src

$(DEPS): %.d : %.utf8.cpp
	set -e; rm -f $@;\
	g++ $< -std=$(CPP_VERSION) -MM ${flags}  > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

$(CC_DEPS): %.d : %.cc
	set -e ; rm -f $@;\
	g++ $< -std=$(CPP_VERSION) -MM ${flags} > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$
$(CPP_DEPS): %.d : %.cpp
	set -e; rm -f $@;\
	g++ $< -std=$(CPP_VERSION) -MM ${flags} > $@.$$$$;\
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

service/ServiceImpl.o : process/*.cxx
	g++ -o $@ -std=$(CPP_VERSION) -c service/ServiceImpl.cxx ${flags}



proto_gen_src/%.pb.cc : proto_src/%.proto 
	$(PROTOC) --cpp_out=proto_gen_src  $< --proto_path=proto_src



.PHONY: clean  db proto bnf clean_bnf_get_set odb_sqlite bnf_one odb_mysql
clean:
	rm  $(OBJS) $(DEPS) $(CC_OBJS) $(CC_DEPS)  -rf

proto:
	$(PROTOC) --cpp_out=proto_gen_src  proto_src/*.proto --proto_path=proto_src
