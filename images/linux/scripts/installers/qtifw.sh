#!/bin/bash -e
################################################################################
##  File:  qtifw.sh
##  Desc:  Installs QtIFW
################################################################################

base_url=https://download.qt.io/online/qtsdkrepository/linux_x64/desktop/tools_ifw
updates_xml_url=$base_url/Updates.xml

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}
# TODO: ideally bypass the creation of the Updates.xml file locally
curl -sLO $updates_xml_url
updates_xml_content=$(curl -s $updates_xml_url)

while read_dom; do
  if [[ $ENTITY = "Name" ]]; then
    # qt.tools.ifw.41
    NAME=$CONTENT
  elif [[ $ENTITY = "Version" ]]; then
    # 4.1.1-202105261130
    VERSION=$CONTENT
  elif [[ $ENTITY = "DownloadableArchives" ]]; then
    # ifw-linux-x64.7z.meta4
    ARCHIVE_NAME=$CONTENT
  fi;
done < Updates.xml

FULL_ARCHIVE_NAME=$VERSION$ARCHIVE_NAME
# https://download.qt.io/online/qtsdkrepository/linux_x64/desktop/tools_ifw/qt.tools.ifw.41/4.1.1-202105261130ifw-linux-x64.7z
regular_url=$base_url/$NAME/$FULL_ARCHIVE_NAME

# TODO: EITHER
# Download with retries, regular
download_with_retries $regular_url "/tmp"
# TODO: OR
# Download via aria2c for speed and reliability
# meta4_url=$base_url/$NAME/$FULL_ARCHIVE_NAME.meta4
# aria2c $meta4_url --dir=/tmp

# Extract
7z x /tmp/$FULL_ARCHIVE_NAME -o/tmp/QtIFW/
# Locate bindir
bindir=$(find /tmp/QtIFW/ -name "bin" -type d)
# Move all executables (should be 5: archivegen  binarycreator  devtool  installerbase  repogen)
mv $bindir/* /usr/local/bin/

invoke_tests "Tools" "QtIFW"
