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
                vim                   \
                net-tools             \
                psmisc                \
                --fix-missing         \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/dbus && mkdir -p /var/run/sshd

CMD ["/usr/sbin/sshd", "-D"]
