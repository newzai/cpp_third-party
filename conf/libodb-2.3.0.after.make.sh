PWD=`pwd`
INSTALL_DIR=${PWD}/../../../local

cp odb/statement-processing.cxx  ${INSTALL_DIR}/include/odb/statement-processing.txx -f
cp odb/details/buffer.cxx  ${INSTALL_DIR}/include/odb/details/buffer.txx -f
cp odb/statement.cxx   ${INSTALL_DIR}/include/odb/statement.txx -f
cp odb/connection.cxx ${INSTALL_DIR}/include/odb/connection.txx2 -f
