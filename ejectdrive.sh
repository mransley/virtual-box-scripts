#!/bin/sh -e
#########################################################
# 1.0 - 2012-03-22 - MR - Initial version
#########################################################
VMNAME=$1

if [ $# -ne 1 ]; then
  echo "$0 : Incorrect number parameters: "
  echo "$0 VMNAME"
  exit 1
fi
VBoxManage storageattach $VMNAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium emptydrive
