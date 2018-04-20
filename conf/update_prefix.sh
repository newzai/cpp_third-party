#./update_prefix.sh 's,\/opt\/local,/root\/jianyu\/local,g'
for conf in ` ls *.conf `;
do
	echo $conf
	sed $@ $conf > $conf.sed
	mv $conf.sed $conf -f
done
