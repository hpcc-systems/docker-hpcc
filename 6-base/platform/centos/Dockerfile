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
                vim-minimal           \
                python34              \
                python34-libs

RUN /usr/bin/ssh-keygen -A
RUN  mkdir -p /var/run/sshd

CMD ["/usr/sbin/sshd", "-D"]
