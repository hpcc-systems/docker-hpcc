FROM ubuntu:xenial

RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates       \
		wget                  \
                libaprutil1           \
                libboost-regex1.58.0  \
                libicu55              \
                libldap-2.4-2         \
                libtbb2               \
                libnuma1              \
                libxml2               \
                libxslt1.1            \
                g++                   \
                openssh-client        \
                openssh-server        \
                expect                \
                rsync                 \
                python                \
                sudo                  \
                libblas3              \
                libatlas3-base        \
                psmisc                \
                libmemcached11        \
                libmemcachedutil2     \
                libpython2.7          \
                libpython3.5          \
                --fix-missing         \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd hpcc && useradd -s /bin/bash -r -m -d /home/hpcc -g hpcc -c "hpcc Runtime User" hpcc

ENV VERSION 7.0.0
ENV FULL_VERSION 7.0.0-beta1
#ENV PLATFORM_DOWNLOAD_MD5  a62b43a1ef1ecf7d8d702d9033e9cf39
ENV PLATFORM_PACKAGE hpccsystems-platform-community_${FULL_VERSION}xenial_amd64.deb

RUN set -x \
   &&  wget  "http://wpc.423a.rhocdn.net/00423A/releases/CE-Candidate-${VERSION}/bin/platform/${PLATFORM_PACKAGE}" \
   #&& echo "$PLATFORM_DOWNLOAD_MD5 ${PLATFORM_PACKAGE}" | md5sum -c - \
   && dpkg -i "${PLATFORM_PACKAGE}" \
   && rm -rf "${PLATFORM_PACKAGE}"

RUN mkdir -p /var/run/dbus && mkdir -p /var/run/sshd
EXPOSE 8010 8002 8015 9876

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash", "-c",  "/usr/sbin/sshd -D"]
