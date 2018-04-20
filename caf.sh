cd build 
git clone https://github.com/actor-framework/actor-framework.git
cd actor-framework
./configure --prefix=/opt/devel/local/ --no-compiler-check --with-log-level=ERROR --build-static-only --with-gcc=/usr/lib/gcc/x86_64-linux-gnu/4.9.3/g++ --no-qt-examples --no-examples  --no-protobuf-examples --no-curl-examples --no-unit-tests 
make -j 16
make install
cd ..
cd ..

