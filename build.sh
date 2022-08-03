
BTARGET=${BTARGET-x86_64}

CFGS=`for t in $BTARGET; do
	cat ./feeds/x/rom/lede/cfg.list | grep "^config.$t$"
done`

export CFGS="`echo $CFGS`"
export WORKFLOW="0"

echo starting build.
echo starting build..
echo starting build...
echo starting build....
df -h .
free -m
echo start build in 10s
sleep 10

mkdir .build_x
echo CONFIG_VERSION_NUMBER=\"`cat release.tag`\" >.build_x/env
sed -i 's,cp feeds/x/rom/lede/$cfg .config,cp $cfg .config,g' ./feeds/x/rom/lede/make.sh
echo 'Printing modded make.sh file below'
echo `cat ./feeds/x/rom/lede/make.sh`
echo 'Present working dir'
echo "$PWD"
./feeds/x/rom/lede/make.sh make -j$1 && sh upload.sh

_EXIT=$?
[ "x$_EXIT" = "x0" ] || {
	make V=s >>../make.log 2>&1
	exit $_EXIT
}