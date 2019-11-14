FROM hpccsystems/hpcc-base:7-el7

ARG version=
RUN if [ -z "${version}" ] ; then echo Missing HPCC version; exit 1; else : ; fi

RUN yum update -y &&  yum install -y \
     curl \
     git  \
     java-1.8.0-openjdk \
     R-core-devel

RUN set -ex; \
    wget http://mysql.mirrors.hoobly.com/Downloads/MySQL-5.6/MySQL-devel-5.6.45-1.el7.x86_64.rpm; \
    rpm -i MySQL-devel-5.6.45-1.el7.x86_64.rpm; \
    rm -rf MySQL-devel-5.6.45-1.el7.x86_64.rpm; \
    \
    wget https://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_0.12.19.tar.gz; \
    R CMD INSTALL Rcpp_0.12.19.tar.gz; \
    rm -rf Rcpp_0.12.19.tar.gz; \
    \
    wget https://cran.r-project.org/src/contrib/Archive/RInside/RInside_0.2.12.tar.gz; \
    R CMD INSTALL RInside_0.2.12.tar.gz; \
    rm -rf RInside_0.2.12.tar.gz; \
    \
    chmod u+s $(which ping); \
    #groupadd hpcc && useradd -s /bin/bash -r -m -d /home/hpcc -g hpcc -c "hpcc Runtime User" hpcc; \
    \
    export VERSION_MMP=${version%-*}; \
    export PLATFORM_PACKAGE=hpccsystems-clienttools-internal_${version}.el7.x86_64.rpm; \
    wget  "http://10.240.32.242/builds/LN-Candidate-${VERSION_MMP}/bin/clienttools/${PLATFORM_PACKAGE}"; \
    #echo "$PLATFORM_DOWNLOAD_MD5 ${PLATFORM_PACKAGE}" | md5sum -c -; \
    yum install --nogpgcheck -y "${PLATFORM_PACKAGE}"; \
    rm -rf  "${PLATFORM_PACKAGE}"

#RUN package-cleanup --leaves --all

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["/usr/sbin/sshd",  "-D"]
