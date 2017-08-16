#!/bin/bash

# Build Trove database images upon Ubuntu base
# Package Requirements: apt install qemu-utils kpartx
# Python Requirements: diskimage-builder needs to be installed (recommend venv)
# Usage: build-trove-image.sh [TROVE_DIR] [API] [TARGET_DATABASE]
#  TROVE_DIR = Directory where copy of Trove source code exists
#  API = API Endpoint for Trove (hardcoded into image, unfortunately)
#  TARGET_DATABASE = What database to build (see TROVE_DIR/integrations/scripts/elements/ubuntu-* for list)

if [ $# -lt 2 ]; then
  echo "Usage: $0 [TROVE_DIR] [API] [TARGET_DATABASE]"
  echo "  TROVE_DIR = Directory where copy of Trove source code exists"
  echo "  API = API Endpoint for Trove"
  echo "  TARGET_DATABASE = What database to build (default:mariadb)"
  exit 1
fi

export DISTRO=ubuntu
export RELEASE=xenial
export DIB_RELEASE=$RELEASE
export SERVICE_TYPE=${3:-mariadb}
export VM=${DISTRO}-${RELEASE}-${SERVICE_TYPE}
# assign a suitable value for each of these environment
# variables that change the way the elements behave.
export HOST_USERNAME=$(whoami)
export HOST_SCP_USERNAME=$HOST_USERNAME
export GUEST_USERNAME=trovedb
export PATH_TROVE=${1}
export CONTROLLER_IP=${2}
export TROVESTACK_SCRIPTS=${PATH_TROVE}/integration/scripts
export SSH_DIR=${PATH_TROVE}/integration/scripts/files/keys
#export SERVICE_TYPE
export ESCAPED_PATH_TROVE=${PATH_TROVE}
#export SSH_DIR
export GUEST_LOGDIR=/tmp/trove-logs
export ESCAPED_GUEST_LOGDIR=${GUEST_LOGDIR}
export DIB_CLOUD_INIT_DATASOURCES="ConfigDrive"
#export DATASTORE_PKG_LOCATION
#export BRANCH_OVERRIDE

# you typically do not have to change these variables
export ELEMENTS_PATH=$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")/diskimage_builder/elements:${PATH_TROVE}/integration/scripts/files/elements
#export ELEMENTS_PATH=$TROVESTACK_SCRIPTS/files/elements
#export ELEMENTS_PATH+=:$PATH_DISKIMAGEBUILDER/elements
#export ELEMENTS_PATH+=:$PATH_TRIPLEO_ELEMENTS/elements
export DIB_APT_CONF_DIR=/etc/apt/apt.conf.d
export DIB_CLOUD_INIT_ETC_HOSTS=true
#local QEMU_IMG_OPTIONS=$(! $(qemu-img | grep -q 'version 1') && echo "--qemu-img-options compat=0.10")

# run disk-image-create that actually causes the image to be built
disk-image-create -a amd64 -o "${VM}" \
    -x ${QEMU_IMG_OPTIONS} ${DISTRO} ${EXTRA_ELEMENTS} vm \
    cloud-init-datasources ${DISTRO}-guest pip-and-virtualenv ${DISTRO}-${SERVICE_TYPE}
