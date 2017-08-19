#!/bin/bash
KERNEL="/kernel"
IMAGE="/images/raspberry.img"

echo "killing all old emulators..."
ps aux | grep [q]emu | awk '{print $2}' | tr '\n' ' ' | sed 's/^/kill /g' | bash

while [ ! -e "$IMAGE" ]; do echo "waiting for image to appear..."; sleep 3; done

echo "starting new emulator..."
qemu-system-arm -kernel "$KERNEL" \
                -cpu arm1176 \
                -m 256 \
                -M versatilepb \
                -serial stdio \
                -append "root=/dev/sda2 rootfstype=ext4 rw" \
                -hda "$IMAGE" \
                -redir tcp:2222::22
