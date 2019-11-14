From centos:7

RUN set -ex; \
    yum update -y; \
    yum install -y \
        epel-release \
        wget                  \
        zip                   \
        rpm-build             \
        curl-devel            \
        freetype6-devel       \
        make                  \
        bison                 \
        flex                  \
        binutils-devel        \
        libldap-devel         \
        libcppunit-devel      \
        libicu-devel          \
        libxslt-devel         \
        boost-devel           \
        openssl-devel         \
        libarchive-devel      \
        v8-devel              \
        java-1.8.0-openjdk-devel   \
        apr-devel             \
        apr-util-devel        \
        hiredis-devel         \
        tbb-devel             \
        numactl-devel         \
        libevent-devel        \
        sqlite-devel          \
        libmemcached-devel    \
        memcached-devel       \
        libtool               \
        automake              \
        make                  \
        m4                    \
        gtk2-devel            \
        atlas-devel           \
        python-devel          \
        gnutls                \
        perl-ExtUtils-MakeMaker \
        libcouchbase-devel; \
    \
    yum install -y  python34-devel;      \
    export git_version=2.9.5; \
    wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-${git_version}.tar.gz; \
    tar -zxvf git-${git_version}.tar.gz; \
    cd git-${git_version}; \
    ./configure; \
    make -j4; \
    make install; \
    cd .. ; \
    rm -rf git-${git_version} git-${git_version}.tar.gz; \
    \
    curl --silent --location https://rpm.nodesource.com/setup_8.x | bash -; \
    yum install -y nodejs; \
    \
    export cmake_version=3.15.2; \
    export cmake_name=cmake-${cmake_version}-Linux-x86_64; \
    wget https://github.com/Kitware/CMake/releases/download/v${cmake_version}/${cmake_name}.tar.gz; \
    tar -zxf ${cmake_name}.tar.gz; \
    rm -rf ${cmake_name}.tar.gz; \
    cp -r ${cmake_name}/bin ${cmake_name}/share /usr/local/ ; \
    rm -rf ${cmake_name}; \
    \
    yum install -y centos-release-scl; \
    yum install -y devtoolset-7; \
    \
    wget http://mysql.mirrors.hoobly.com/Downloads/MySQL-5.6/MySQL-devel-5.6.45-1.el7.x86_64.rpm; \
    rpm -i MySQL-devel-5.6.45-1.el7.x86_64.rpm; \
    rm -rf MySQL-devel-5.6.45-1.el7.x86_64.rpm; \
    \
    yum install -y R-core-devel; \
    wget https://cran.r-project.org/src/contrib/Archive/Rcpp/Rcpp_0.12.19.tar.gz; \
    R CMD INSTALL Rcpp_0.12.19.tar.gz; \
    rm -rf Rcpp_0.12.19.tar.gz; \
    \
    wget https://cran.r-project.org/src/contrib/Archive/RInside/RInside_0.2.12.tar.gz; \
    R CMD INSTALL RInside_0.2.12.tar.gz; \
    rm -rf RInside_0.2.12.tar.gz

# Import GPG key
RUN set -ex; \
  wget http://10.240.32.242/data3/build/gpg/HPCCSystems.priv; \
  #aws s3 cp s3://@S3_BUCKET@/HPCCSystems.priv . ; \
  #gpg --passphrase @GPG_PASSPHRASE@  --import HPCCSystems.priv; \
  gpg --passphrase icanspellthis  --import HPCCSystems.priv; \
  rm -rf HPCCSystems.priv
