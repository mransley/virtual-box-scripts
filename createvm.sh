#!/bin/sh -e
#########################################################
# 1.0 - 2012-03-20 - MR - Initial version
# 1.1 - 2012-03-21 - MR - Added in creation of the kickstart
#########################################################
BASE_VM_PATH=/virtualmachines
DVD_BASE_PATH=/storage/software/iso
OSTYPE=$1
VMNAME=$2
IP=$3
HDD_SIZE=$4
RAM_SIZE=$5

if [ $# -ne 5 ]; then
  echo "$0 : Incorrect number parameters: "
  echo "$0 OSTYPE <Fedora_64|RedHat_64|Windows2003> VMNAME IP HDD_SIZE RAM_SIZE"
  echo "$0 RedHat_64 portal7-01.justnudge.com 122 20480 1024"
  exit 1
fi

# Setup the Installer Image
if [ "$OSTYPE" = "Fedora_64" ]; then
   DVD_PATH=$DVD_BASE_PATH/Fedora-16-x86_64-DVD.iso
fi
if [ "$OSTYPE" = "RedHat_64" ]; then
   DVD_PATH=$DVD_BASE_PATH/CentOS-6.2-x86_64-bin-DVD1.iso
fi
if [ "$OSTYPE" = "Windows2003" ]; then
   DVD_PATH=$DVD_BASE_PATH/windows_2003.iso
fi

if [ ! -f $DVD_PATH ]; then
   echo "$0 : Unable to locate the DVD path for OS Type $OSTYPE and DVD Path '$DVD_PATH'"
   exit 1
fi

mkdir -p $BASE_VM_PATH/$VMNAME
echo "Creating storage"
VBoxManage createhd --filename $BASE_VM_PATH/$VMNAME/$VMNAME.vdi --size $HDD_SIZE
echo "Creating VM"
VBoxManage createvm --name $VMNAME --ostype $OSTYPE --register
echo "Attaching storage"
VBoxManage storagectl $VMNAME --name "IDE Controller" --add ide
VBoxManage storageattach $VMNAME --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $DVD_PATH
VBoxManage storageattach $VMNAME --storagectl "IDE Controller" --port 0 --device 1 --type hdd --medium $BASE_VM_PATH/$VMNAME/$VMNAME.vdi
VBoxManage modifyvm $VMNAME --ioapic on
echo "Setting up boot order"
VBoxManage modifyvm $VMNAME --boot1 dvd --boot2 disk --boot3 none --boot4 none
echo "Setting up system memory"
VBoxManage modifyvm $VMNAME --memory $RAM_SIZE
VBoxManage modifyvm $VMNAME --vram 24
echo "Setting up networking"
VBoxManage modifyvm $VMNAME --nic1 bridged --nictype1 82540EM --bridgeadapter1 em1
echo "Setting up multiple CPU's"
VBoxManage modifyvm $VMNAME --cpus 2
echo "Setting up shared folders"
VBoxManage sharedfolder add $VMNAME --name "software" --hostpath "/storage/software/"
echo "Setting up Remote Desktop"
VBoxManage modifyvm $VMNAME --vrde on
VBoxManage modifyvm $VMNAME --vrdeport 33$IP
echo "Build Complete"
echo "Run VBoxManage startvm $VMNAME --type headless"
