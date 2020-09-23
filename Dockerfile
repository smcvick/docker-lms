FROM ubuntu:xenial
MAINTAINER Sean McVicker <smcvick.c@gmail.com>

ENV SQUEEZE_VOL /srv/squeezebox
ENV LANG C.UTF-8
ENV DEBIAN_FRONTEND noninteractive

# get various libraries needed for LMS
RUN apt-get update && \
	apt-get -y install \
		curl \
		wget \
		faad \
		flac \
		lame \
		sox \
		libio-socket-ssl-perl \
		tzdata \
		&& \
	apt-get clean

# define url that will be used to query current url of the latest debian amd64 7.9.x package
ENV PACKAGE_VERSION_URL=http://www.mysqueezebox.com/update/?version=7.9&revision=1&geturl=1&os=debamd64

# get the LMS package itself
RUN pkg_url=$(curl "$PACKAGE_VERSION_URL") && \
	curl -Lsf -o /tmp/logitechmediaserver.deb $pkg_url && \
	dpkg -i /tmp/logitechmediaserver.deb && \
	rm -f /tmp/logitechmediaserver.deb && \
	apt-get clean

# This will be created by the entrypoint script.
RUN userdel squeezeboxserver

VOLUME $SQUEEZE_VOL
EXPOSE 3483 3483/udp 9000 9090

# scripting setup
COPY entrypoint.sh /entrypoint.sh
COPY start-squeezebox.sh /start-squeezebox.sh
RUN chmod 755 /entrypoint.sh /start-squeezebox.sh

# set entrypoint script
ENTRYPOINT ["/entrypoint.sh"]
