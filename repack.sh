#!/bin/sh

. /etc/os-release

ORG_NAME=alt-autorepacked

BASE_REMOTE_URL=https://github.com/alt-autorepacked

_get_suffix() {
    if [ -n "$ALT_BRANCH_ID" ]; then
        suffix=".$ALT_BRANCH_ID"
    else
        suffix=".$(epm print info -r)"
    fi
    echo ".$(epm print info -a)$suffix.rpm"
}

_check_version_from_remote() {
    suffix="*$(_get_suffix)"
    url=$(epm --quiet tool eget -q --list --latest $BASE_REMOTE_URL/$_package/releases "$suffix")
    filename="${url##*/}"
    version=$(echo $filename | grep -oP '\K[0-9]+\.[0-9]+\.[0-9]+')
    echo $version
}

_check_version_from_download() {
    search="*$(_get_suffix)"
    echo $(rpm -qp --queryformat '%{VERSION}' $search)
}

_add_repo_suffix() {
    if [ -n "$ALT_BRANCH_ID" ]; then
        suffix=".$ALT_BRANCH_ID"
    else
        suffix=".$(epm print info -r)"
    fi
    for file in *.rpm; do
        if [ ! -f "$file" ]; then
            continue
        fi
        base="${file%.rpm}"e
        new_filename="${base}${suffix}.rpm"
        mv "$file" "$new_filename"
    done
}

_create_release() {
    suffix="*.$(epm print info -a).$(epm print info -r).rpm"
    gh release create $TAG -R $ORG_NAME/$_package --notes "[CI] automatic release"
    gh release upload $TAG -R $ORG_NAME/$_package $suffix
}

########

_package="vk-messenger"

_download() {
    epm -y repack "https://upload.object2.vk-apps.com/vk-me-desktop-dev-5837a06d-5f28-484a-ac22-045903cb1b1a/latest/vk-messenger.rpm"
}

_download
_add_repo_suffix
download_version=$(_check_version_from_download)
remote_version=$(_check_version_from_remote)

if [ "$remote_version" != "$download_version" ]; then
    TAG="v$download_version"
    _create_release
    echo "Release created: $TAG"
else
    echo "No new version to release. Current version: $download_version"
fi

