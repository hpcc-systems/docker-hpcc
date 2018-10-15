FROM hpccsystems/hpcc-base:7-el7

RUN yum install -y curl
#RUN yum install -y java-1.8.0-openjdk
RUN chmod u+s $(which ping)
#RUN groupadd hpcc && useradd -s /bin/bash -r -m -d /home/hpcc -g hpcc -c "hpcc Runtime User" hpcc

ENV VERSION 7.0.0
ENV FULL_VERSION 7.0.0-1
#ENV PLATFORM_DOWNLOAD_MD5  c435045d4319880f141e8faf23555b83
ENV PLATFORM_PACKAGE hpccsystems-platform-community_${FULL_VERSION}.el7.x86_64.rpm

RUN set -x \
   &&  wget  "http://wpc.423a.rhocdn.net/00423A/releases/CE-Candidate-${VERSION}/bin/platform/${PLATFORM_PACKAGE}" \
   #&& echo "$PLATFORM_DOWNLOAD_MD5 ${PLATFORM_PACKAGE}" | md5sum -c - \
   && yum install --nogpgcheck -y "${PLATFORM_PACKAGE}" \
   && rm -rf  "${PLATFORM_PACKAGE}"

EXPOSE 8010 8002 8015 9876

RUN cp -r /home/hpcc/.ssh ~/
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd",  "-D"]
