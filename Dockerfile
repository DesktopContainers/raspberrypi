FROM desktopcontainers/base-debian

MAINTAINER MarvAmBass (https://github.com/DesktopContainers)

RUN apt-get -q -y update && \
    apt-get -q -y install wget \
                          telnet \
                          qemu-system-arm \
                          util-linux && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget -O raspbian-lite.zip https://downloads.raspberrypi.org/raspbian_lite_latest && \
    unzip raspbian-lite.zip && \
    rm raspbian-lite.zip && \
    mv *.img /raspberry.img && \
    mkdir /images && \
    wget -O /kernel "https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-4.4.34-jessie?raw=true" && \
    sed -i 's/starting services"/starting services"\n\npatch-image.sh \/raspberry.img || exit 1\n\n/g' /usr/local/bin/entrypoint.sh && \
    chmod a+rw /raspberry.img /kernel && \
    echo "rpi.sh \$*" >> /bin/ssh-app.sh

RUN sed -i -e "s/Exec=ssh.*/&'/g" -e "s/Exec=ssh/Exec=\/bin\/bash -c 'while [ \$(pstree | grep [s]u | grep sh | grep tail ; echo \$?) -ne 0 ]; do sleep 10; done;/g" \
    /usr/local/bin/entrypoint.sh

COPY patch-image.sh /usr/local/sbin/
COPY rpi.sh /usr/local/bin/

EXPOSE 2222
VOLUME ["/images"]

COPY docker-healthcheck /usr/local/bin/
HEALTHCHECK CMD ["docker-healthcheck"]
