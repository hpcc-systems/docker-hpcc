FROM centos:7

RUN yum update -y && yum install -y \
                epel-release          \
		wget                  \
                gcc-c++               \
                boost-regex           \
                openldap              \
                libicu                \
                m4                    \
                libtool               \
                libxslt               \
                libxml                \
                openssh-server        \
                openssh-clients       \
                expect                \
                libarchive            \
                rsync                 \
                apr                   \
                apr-util              \
                zip                   \
                tbb                   \
                net-tools             \
                sudo                  \
                psmisc                \
                blas.x86_64           \
                atlas.x86_64          \
                which                 \
                numa-libs             \
                python34              \
                python34-libs

RUN chmod u+s $(which ping)
#RUN groupadd hpcc && useradd -s /bin/bash -r -m -d /home/hpcc -g hpcc -c "hpcc Runtime User" hpcc

RUN /usr/bin/ssh-keygen -A

ENV VERSION 6.4.20
ENV FULL_VERSION 6.4.20-1
#ENV PLATFORM_DOWNLOAD_MD5  a62b43a1ef1ecf7d8d702d9033e9cf39
ENV PLATFORM_PACKAGE hpccsystems-platform-community_${FULL_VERSION}.el7.x86_64.rpm

RUN set -x \
   &&  wget  "http://wpc.423a.rhocdn.net/00423A/releases/CE-Candidate-${VERSION}/bin/platform/${PLATFORM_PACKAGE}" \
   #&& echo "$PLATFORM_DOWNLOAD_MD5 ${PLATFORM_PACKAGE}" | md5sum -c - \
   && yum install --nogpgcheck -y "${PLATFORM_PACKAGE}" \
   && rm -rf  "${PLATFORM_PACKAGE}"

#RUN mkdir -p /var/run/dbus
RUN  mkdir -p /var/run/sshd
EXPOSE 8010 8002 8015 9876

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["bash", "-c",  "/usr/sbin/sshd -D"]
