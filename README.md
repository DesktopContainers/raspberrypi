# Raspberry Pi
_Raspberry Pi virtual machine in Qemu_

This is a container for emulating the raspbian lite distribution inside a qemu emulated raspberry pi.

You can get the QEMU Window via _ssh -X/VNC/noVNC (http)_. You can also directly connect to the qemu raspberry on port 2222.

You can only connect once to one container. if you want multiple raspberrys, run the docker container multiple times.

_Attention: If you use ssh -X to get the qemu window - running instances of the qemu raspberry will be killed and boot again (which takes some time), better use novnc or vnc if you want raspberry with gui_

_The Docker Healthcheck checks if ssh of raspberry is reachable_

It's based on __DesktopContainers/base-mate__

## Usage: Run the Client

### Exposed Ports

*__2222__ _for ssh connection to the qemu raspberry pi (raspbian lite)_

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

        docker start raspberrypi || docker run -d --name raspberrypi -p 2222:2222 --privileged desktopcontainers/raspberrypi
     
  2.1 Connect directly to the qemu raspberry via ssh. (Keep an eye on docker healthcheck status - ssh is available when it's healthy)
  
        ssh -p 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no pi@localhost
        
  2.2 Connect to the server using `ssh -X` (every time the old raspberry gets killed). 
     _Logging in with `ssh` automatically opens qemu raspberry window_

        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no \
        -X app@$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' raspberrypi)
