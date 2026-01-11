git push origin
export VERSION=`git describe --tags --abbrev=0 2>/dev/null || echo v1`
2>/dev/null git tag -d $VERSION || true
2>/dev/null git push --delete origin $VERSION || true
git tag $VERSION
git push origin $VERSION
