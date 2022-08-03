
change=

cat target.list | while read target; do
	test -n "$1" && {
		echo $target | grep -q "$1" || continue
	}
	TAG="`cat release.tag`"
	BTARGET="`echo -n $target | gsed 's/BTARGET=//'`"
	ASSET_NAME=`echo "x-wrt-${TAG}-${BTARGET}" | tr ' ' _`
	ASSET_ID=`echo ${ASSET_NAME} | md5sum | head -c32`
	TARGETNAME=`echo ${BTARGET} | tr ' ' _`
	echo push ${ASSET_NAME}

	test -n "$change" || {
		cat release-header.yml | gsed "s/_TAG_/${TAG}/g" >.github/workflows/release.yml
		change=1
	}
	cat release-main.yml | gsed "s/_TARGET_/${BTARGET}/g;s/_TARGETNAME_/${TARGETNAME}/g;s/_ASSET_NAME_/${ASSET_NAME}/g;s/_ASSET_ID_/${ASSET_ID}/g" >>.github/workflows/release.yml
	for bt in $BTARGET; do
		ASSET_NAME=`echo "x-wrt-${TAG}-${bt}" | tr ' ' _`
		ASSET_ID=`echo ${ASSET_NAME} | md5sum | head -c32`
		cat release-upload-one.yml | gsed "s/_TARGET_/${BTARGET}/g;s/_TARGETNAME_/${TARGETNAME}/g;s/_ASSET_NAME_/${ASSET_NAME}/g;s/_ASSET_ID_/${ASSET_ID}/g" >>.github/workflows/release.yml
	done
done

# git diff release.tag || exit 0

TAG="v`cat release.tag`"
git commit --signoff -am "release: $TAG" && \
		git tag $TAG && \
		git push -f --tags origin parallel-jobs 
