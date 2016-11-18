FROM desktopcontainers/base-mate

MAINTAINER MarvAmBass (https://github.com/DesktopContainers)

RUN apt-get -q -y update && \
    apt-get -q -y install wget \
                          qemu-system-arm \
                          util-linux && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -O raspbian-lite.zip https://downloads.raspberrypi.org/raspbian_lite_latest && \
    unzip raspbian-lite.zip && \
    rm raspbian-lite.zip && \
    mv *.img /raspberry.img && \
    wget -O /kernel https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/kernel-qemu-4.4.13-jessie && \
    sed -i 's/^# exec CMD/patch-image.sh \/raspberry.img || exit 1\n\n#exec CMD/g' /opt/entrypoint.sh && \
    chmod a+rw /raspberry.img /kernel

COPY patch-image.sh /usr/local/sbin/
COPY rpi.sh /usr/local/bin/

RUN echo "#!/bin/bash\nrpi.sh \$*\n" > /bin/ssh-app.sh;

COPY docker-healthcheck /usr/local/bin/
HEALTHCHECK CMD ["docker-healthcheck"]
