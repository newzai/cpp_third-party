#!/bin/bash


mkdir -p .result
mkdir -p .result/download
mkdir -p build
mkdir -p download





LIB_DIR=`pwd`
echo $LIB_DIR

CPUS=4

### install libs ....

build_pgk ( ) {
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
			make  -s
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
