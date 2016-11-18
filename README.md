# Raspberry Pi
_Raspberry Pi virtual machine in Qemu_

This is a container for emulating the raspbian lite distribution inside a qemu emulated raspberry pi.

It's based on __DesktopContainers/base-mate__

## Usage: Run the Client

### Passwords

*__User:__ pi
*__Password:__ raspberry

### Environment variables and defaults

* __FS\_EXTEND\_GB__
 * default: _8_ - can be any number to increase fs size of rootfs.
* __RC\_LOCAL\_COMAND__
 * no default - bash comands to include in rc.local

### Simple SSH X11 Forwarding

Since it is an X11 GUI software, usage is in two steps:
  1. Run a background container as server or start existing one.

        docker start raspberrypi || docker run -d --name raspberrypi --privileged desktopcontainers/raspberrypi
        
  2. Connect to the server using `ssh -X` (as many times you want). 
     _Logging in with `ssh` automatically opens easytag_

        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
        -X app@$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' raspberrypi)
