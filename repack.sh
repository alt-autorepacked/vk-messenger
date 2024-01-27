#!/bin/sh

epm tool eget https://raw.githubusercontent.com/alt-autorepacked/common/v0.1.0/common.sh

. ./common.sh

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

rm common.sh
