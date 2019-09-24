From hpccsystems/hpcc-ln-dev:7-el7 AS el7-builder
# Usage: sudo docker build -t <image tag> --build-arg branch=<HPCC branch or tag> --build-arg owner=<platform owner>  .
#     or sudo docker build -t <image tag> --build-arg branch=<HPCC branch or tag> --build-arg owner=<platform owner> --build-arg user=<user> --build-arg password=<password>  .
#     or sudo docker build -t <image tag> --build-arg branch=<HPCC branch or tag> --build-arg ln_owner=<ln user> --build-arg ln_user=<user> --build-arg ln_password=<password>  --build-arg ln_branch=<ln branch>.
# The default branch is "master". The default github user is "hpcc-systems".
ARG branch=
ARG ln_branch=
ARG owner="hpcc-systems"
ARG user=
ARG password=
ARG ln_owner="hpcc-systems"
ARG ln_user=
ARG ln_password=
ARG passphrase=

WORKDir /hpcc-dev
RUN set -ex; \
   if [ -z "${user}" ] ; \
   then \
      git clone https://github.com/${owner}/HPCC-Platform.git; \
   else \
      echo "machine github.com login ${user} password ${password}" > ~/.netrc ; \
      git clone https://github.com/${owner}/HPCC-Platform.git; \
   fi; \
   cd HPCC-Platform; \
   if [ -n "${branch}" ] ; \
   then \
      rc=$(git tag | grep ${branch}) || : ; \
      if [ "$rc" ]; \
      then \
         git fetch && git fetch --tags; \
      else : ; fi; \
      git checkout ${branch}; \
   else : ; fi; \
   git submodule update --init --recursive; \
   cd ..; \
   if [ -z "${ln_user}" ] ; \
   then \
      git clone https://github.com/${ln_owner}/LN.git; \
   else \
      echo "machine github.com login ${ln_user} password ${ln_password}" > ~/.netrc; \
      git clone https://github.com/${ln_owner}/LN.git; \
   fi; \
   if [ -n "${branch}" ] ; \
   then \
      cd LN; \
      git tag | grep ${branch}; \
      if [ $? -eq 0 ]; \
      then \
         git fetch && git fetch --tags; \
      fi; \
      git checkout ${branch}; \
      cd .. ; \
   else : ; fi; \
   mkdir -p build; \
   cd build; \
   rm -rf * ; \
   source /opt/rh/devtoolset-7/enable; \
   if [ -n "${passphrase}" ] ; \
   then \
      cmake -DBUILD_LEVEL=INTERNAL -DCMAKE_CXX_FLAGS=-D_DALIUSER_STACKTRACE -DUSE_LIBARCHIVE=false -DUSE_OPTIONAL=ON -DINCLUDE_PLUGINS=ON -DSUPPRESS_SPARK=ON -DUSE_SHLIBDEPS=ON -DUSE_MYSQL=ON -DUSE_MYSQL=ON -DSIGN_MODULES=ON -DSIGN_MODULES_PASSPHRASE=${passphrase} -DSIGN_MODULES_KEYID=8DAA417D ../LN; \
   else \
      cmake -DBUILD_LEVEL=INTERNAL -DCMAKE_CXX_FLAGS=-D_DALIUSER_STACKTRACE  -DUSE_LIBARCHIVE=false -DUSE_OPTIONAL=ON -DINCLUDE_PLUGINS=ON -DSUPPRESS_SPARK=ON  -DUSE_SHLIBDEPS=ON -DUSE_MYSQL=ON -DUSE_MYSQL=ON ../LN; \
   fi; \
   make -j 4 ; \
   make package


From hpccsystems/hpcc-base:7-el7

WORKDir /Downloads
COPY --from=0 /hpcc-dev/build/hpccsystems*.rpm .

RUN yum update -y &&  yum install -y \
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
   groupadd hpcc && useradd -s /bin/bash -r -m -d /home/hpcc -g hpcc -c "hpcc Runtime User" hpcc ; \
   yum install --nogpgcheck -y hpccsystems*.rpm; \
   rm -rf  hpccsystems*.rpm

#RUN cp -r /home/hpcc/.ssh ~/
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
