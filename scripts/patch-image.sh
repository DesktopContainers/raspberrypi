#!/bin/bash

IMAGE=$1
IMAGE_PATCHED="/images/raspberry.img"

if [ -e "$IMAGE_PATCHED" ]; then
  chmod a+rw "$IMAGE_PATCHED"
  echo "patched image already found... (skipping patching - just start the image)"
  exit 0
fi

if [ -z ${FS_EXTEND_GB+x} ]; then
  FS_EXTEND_GB=8
fi

if [ -e "$IMAGE" ]; then
  echo "patching image: $IMAGE"
  
  MULTIPLICATOR=$(fdisk -l "$IMAGE" | grep '*' | cut -d'*' -f2 | cut -d' ' -f2)
  PART2_START=$(fdisk -l "$IMAGE" | grep 'img2' | awk '{print $2}')
  PART2_MOUNT_OFFSET=$(python -c "print($PART2_START*$MULTIPLICATOR)")

  echo
  echo "variables:"
  echo " -MULTIPLICATOR = $MULTIPLICATOR"
  echo " -PART2_START = $PART2_START"
  echo " -PART2_MOUNT_OFFSET = $PART2_MOUNT_OFFSET"

  echo
  echo "expanding raspberry fs..."
  truncate -s +$FS_EXTEND_GB"G" "$IMAGE"
  echo "expanding raspberry partitiontable..."
fdisk "$IMAGE" << EOF
d
2
n
p
2
$PART2_START

w
q
EOF

  echo
  echo "mounting second partition"
  mount -v -o offset=$PART2_MOUNT_OFFSET -t ext4 "$IMAGE" /mnt || exit 2

  echo
  echo "patching..."

  echo " - /etc/ld.so.preload"
  sed -i 's/^/#/g' /mnt/etc/ld.so.preload

  echo " - /etc/fstab"
  sed -i 's,^/dev,#,g' /mnt/etc/fstab
  echo "/dev/sda1 /boot vfat defaults 0 2" >> /mnt/etc/fstab

  echo " - /etc/rc.local"
  sed -i 's/^exit.*//g' /mnt/etc/rc.local
  echo "resize2fs /dev/sda2 || exit 1" >> /mnt/etc/rc.local
  echo "service ssh start" >> /mnt/etc/rc.local

  if [ -z ${RC_LOCAL_COMAND+x} ]; then
    echo "$RC_LOCAL_COMAND" >> /mnt/etc/rc.local
  fi
  
  echo "exit 0" >> /mnt/etc/rc.local

  umount /mnt || exit 3
  
  mv "$IMAGE" "$IMAGE_PATCHED"
  chmod a+rw "$IMAGE_PATCHED"

  exit 0
fi

exit 1
