#!/bin/sh
set -e
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

echo "-------------------------------------------------------------------------------------------------------------"
echo "Welcome to wax, a shim modifying automation tool made by CoolElectronics and Sharp_Jack, greatly improved by r58playz and Rafflesia"
echo "Prerequisites: cgpt must be installed, program must be ran as root, chromebrew.tar.gz needs to exist"
echo "-------------------------------------------------------------------------------------------------------------"
echo "Launch flags you should know about: --antiskid will relock the rootfs"
echo "THIS IS THE MINIMAL SHIM, CHROMEBREW PAYLOADS **WILL NOT** WORK"
# ORDER MATTERS! bin name before flags

bin=$1

echo "Expanding bin for 'arch' partition. this will take a while"
echo -ne "\a"

# Fix corrupt gpt
fdisk $bin <<EOF
w

EOF

echo "Creating loop device"
loop=$(losetup -f)
losetup -P ${loop} ${bin}

echo "Making ROOT mountable"
sh make_dev_ssd_no_resign.sh --remove_rootfs_verification -i ${loop}

echo "Creating Mountpoint"
mkdir mnt || :

echo "Mounting ROOT-A"
mount "${loop}p3" mnt

echo "Injecting payload"
cp -rv sh1mmer-assets mnt/usr/share/sh1mmer-assets
cp -v sh1mmer-scripts/* mnt/usr/sbin/
mkdir mnt/usr/local/payloads/
cp -rv payloads-mini/* mnt/usr/local/payloads/
cp -v factory_install.sh mnt/usr/sbin/

sync # this sync should hopefully stop make_dev_ssd from messing up, as it does raw byte manip stuff
sleep 4

sleep 2
echo "Cleaning up..."

sync
if umount "${loop}p3"; then
    losetup -d ${loop}
else
    echo "Couldn't safely unmount. Please unmount and detach the loopbacks yourself."
fi

echo "Done. Have fun!"
