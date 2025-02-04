
test -n "$1" || {
	echo "sh $0 <target>"
	exit 1
}

cat target.list | while read target; do
	test -n "$1" && {
		echo $target | grep -q "$1" || continue
	}
	TAG="`cat release.tag`""`echo -n $target | gsed 's/TARGET//'`"
	echo push $TAG
	sleep 2

	gsed -i "s/name: x-wrt-.*=.*/name: x-wrt-$TAG/g" .github/workflows/main.yml && \
		gsed -i "s/TARGET=.* sh /$target sh /" .github/workflows/main.yml && \
		git commit --signoff -am "release: $TAG" && \
		git push -f --tags origin master || exit 1
done

# TAG="v`cat release.tag`"
# git commit --signoff -am "release: $TAG" && \
# 		git tag $TAG && \
# 		git push -f --tags origin parallel-jobs 