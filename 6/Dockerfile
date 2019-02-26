FROM hpccsystems/hpcc-base:6-xenial

RUN apt-get update && apt-get install -y iputils-ping
RUN groupadd hpcc && useradd -s /bin/bash -r -m -d /home/hpcc -g hpcc -c "hpcc Runtime User" hpcc

ENV VERSION 6.4.36
ENV FULL_VERSION 6.4.36-1
#ENV PLATFORM_DOWNLOAD_MD5  a62b43a1ef1ecf7d8d702d9033e9cf39
ENV PLATFORM_PACKAGE hpccsystems-platform-community_${FULL_VERSION}xenial_amd64.deb

RUN set -x \
   &&  wget  "http://wpc.423a.rhocdn.net/00423A/releases/CE-Candidate-${VERSION}/bin/platform/${PLATFORM_PACKAGE}" \
   #&& echo "$PLATFORM_DOWNLOAD_MD5 ${PLATFORM_PACKAGE}" | md5sum -c - \
   && dpkg -i "${PLATFORM_PACKAGE}" \
   && rm -rf "${PLATFORM_PACKAGE}"

EXPOSE 8010 8002 8015 9876

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd", "-D"]
