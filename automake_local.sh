

mkdir -p .result
mkdir -p .result/download
mkdir -p build
mkdir -p download




if [ ! -e .result/yum.ok ]; then
	echo "yum install rsync wget  flex byacc byacc-devel bison bison-devel mysql-devel mysql-libs unixODBC openssh-clients freetds unixODBC-devel libtool openssl-devel gmp-devel libpcap-devel gcc gcc-c++"	
	yum install git cmake rsync wget  flex byacc byacc-devel bison bison-devel mysql-devel mysql-libs unixODBC openssh-clients freetds unixODBC-devel libtool openssl-devel gmp-devel libpcap-devel gcc gcc-c++
	if [ $? != 0 ];then
		echo "yum install fail..."
		exit 1
	fi
	
	echo 0 > .result/yum.ok
fi

LIB_DIR=`pwd`
echo $LIB_DIR

CPUS=`cat /proc/cpuinfo  | grep processor | wc -l`
echo "CPUS $CPUS"


function download(){
	if [ -d download ] ; then

		for conf in `ls download/*.wget` ;
		do
			if [ ! -e .result/$conf.ok ] ;then
				sh $conf
				if [ $? != 0 ] ; then 
					echo  "$conf fail...." 
				else 
					echo 0 > .result/$conf.ok 
				fi
			else
				echo "`cat $conf` -------- already download..."
			fi
		done;
	fi
	

}

#download


###install gcc 4.9.2 ,suport c++1y
echo "check gcc,g++ "

if [ ! -e  .result/gcc.1y.ok ]; then

	echo "#include<cstdlib>" > test1y.cxx
	echo "int main( int argc, char ** argv) { return 0;}" >> test1y.cxx
	g++ -std=c++1y test1y.cxx -o test1y
	if [ $? != 0 ];then
		if [ ! -d build/gcc-4.9.2 ];then
			if [ ! -f gcc-4.9.2.tar.bz2 ];then
				echo "gcc-4.9.2.tar.bz2 file not exist..."			
				exit 1
			fi
			cd build
				tar jxvf ../gcc-4.9.2.tar.bz2
				cd gcc-4.9.2
					cp ../../download_prerequisites contrib/ -rf
					cp ../../cloog-0.18.1.tar.gz . -rf
					cp ../../mp* . -rf
					cp ../../gmp-4.3.2.tar.bz2 . -rf
					./contrib/download_prerequisites
				cd ..
			cd ..
		fi
		cd build	
		mkdir -p gcc-build-4.9.2
		cd gcc-build-4.9.2
		if [ ! -f Makefile ] ;then
			../gcc-4.9.2/configure --enable-checking=release --enable-languages=c,c++ --disable-multilib --with-dwarf2 --build=x86_64-redhat-linux
		fi

		if [ ! -f gcc-4.9.2.make.ok ]; then
			make -j$CPUS
			if [ $? != 0 ];then
				echo "make  -j$CPUS gcc 4.9.2 error.try again...."
				exit 1
			fi
			echo 0 > ../../.result/gcc-4.9.2.make.ok

			make install
			echo " build gcc 4.9.2 ok..."
		fi
		cd ..
		cd ..
	
	else
		rm test1y.cxx test1y -rf
		echo 0 > .result/gcc.1y.ok
		echo "g++ support c++1y"
	
	fi

fi

### install libs ....

function build_pgk(){
	pgk=$1
	shift
	pgk_dir=$1
	shift

	echo "build ~~$pgk~~$pgk_dir~~$@"
	
	if [ -f configure ];then
		if [ ! -f Makefile ]; then
			cat ../../conf/$pgk_dir.conf
			sh ../../conf/$pgk_dir.conf
			if [ $? != 0 ]; then
				echo "configure $pgk_dir error.."
				exit 1;
			fi
		else
			echo "already configrue..."
		fi
		if [ ! -f $pgk_dir.make.ok ]; then
			
			echo "$PWD make -j$CPUS -s "
			make -j$CPUS -s
			if [ $? != 0 ]; then
				make -j$CPUS   # retry again
				if [ $? != 0 ]; then
					echo "make  -j$CPUS $pgk_dir error.."
					exit 1
				fi
			fi
			echo 0 > $pgk_dir.make.ok
			echo 0 > ../../.result/$pgk.make.ok
			make install 
			if [ -e ../../conf/$pgk_dir.after.make.sh ] ;then
				cat ../../conf/$pgk_dir.after.make.sh
				sh ../../conf/$pgk_dir.after.make.sh
		
			fi
		else
			echo "$pgk_dir alreay make.."
			echo 0 > ../../.result/$pgk.make.ok
		fi
	else
		echo "no configure file.."
		##for boost ./bootstrap.sh
		if [ -f bootstrap.sh ] ;then
			if [ ! -e b2 ] ;then
				./bootstrap.sh
			fi
			if [ ! -f $pgk_dir.make.ok ]; then
				cat ../../conf/$pgk_dir.conf
                        	sh ../../conf/$pgk_dir.conf 
				if [ $? != 0 ]; then
					echo "build boost fail..."
					exit 1
				fi
				echo 0 > $pgk_dir.make.ok
				echo 0 > ../../.result/$pgk.make.ok
			else
				echo "$pgk_dir alreay make.."
				echo 0 > ../../.result/$pgk.make.ok
			fi
		else
			if [ ! -e ../../conf/$pgk_dir.ignore ] ;then
			 	cat ../../conf/$pgk_dir.conf
			 	sh ../../conf/$pgk_dir.conf
			 	if [ $? != 0 ]; then
					echo "using conf/$pgk_dir.ignore "
                                	echo "mak $pgk_dir error.."
                                	exit 1
                         	fi
			 	echo 0 > $pgk_dir.make.ok
			 	echo 0 > ../../.result/$pgk.make.ok
			fi
		fi
	fi
}


for pgk in `ls *.tar.gz ` ;
do 
	if [ $pgk = "cloog-0.18.1.tar.gz"  ] ;then
		echo "ignore $pgk"		
		continue
	fi
	if [  $pgk = "mpc-0.8.1.tar.gz" ] ; then
		echo "ignore $pgk"		
		continue	
	fi
	if [ -e .result/$pgk.make.ok ] ;then
		echo "$pgk alreay make & install.."
		continue;
	fi
	tar -tf $pgk > $pgk.list
	while read line
	do
		pgk_dir=${line%/*}
		break;
	done < $pgk.list
	
	rm $pgk.list -rf

	echo "pgk_dir: $pgk_dir"
	cd build
	
	if [ ! -d $pgk_dir ];then
		echo "tar zxf $pgk"
		tar zxf ../$pgk;
	fi
	if [ ! -d $pgk_dir ]; then
		echo "$pgk tar zxvf dir is not match $pgk_dir can not auto build.;" 
		exit 1;
	fi
	
	
	if [ ! -e ../conf/$pgk_dir.conf ]; then
		echo "file ../conf/$pgk_dir.conf not found...."
		if [ ! -e ../conf/$pgk_dir.ignore ]; then
			echo " file ../conf/$pgk_dir.ignore not found .."
			exit 1
		else
			cd ..
			continue
		fi
	fi
	
	cd $pgk_dir
		
		build_pgk $pgk  $pgk_dir 
	
	cd ..
	cd ..
	
done;

cd ..


echo "auto make all libs ok...."
