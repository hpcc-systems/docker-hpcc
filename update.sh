#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )

# ./update.sh "6.4.14-1 6.4.16-rc1"
if [ ${#versions[@]} -eq 0 ]; then
        versions=( */ )
fi

versions=( "${versions[@]%/}" )


travisEnv=
for full_version in "${versions[@]}"; do

   major_version=$(echo "$full_version" | cut -d '.' -f1)
   version=$(echo "$full_version" | cut -d '-' -f1)
   maturity=$(echo "$full_version" | cut -d '-' -f2)
   dir="${major_version}"
   if [ "${maturity:0:2}" = "rc" ]
   then
      dir="${dir}-rc"
   elif  [ "${maturity:0:4}" = "beta" ]
   then
      dir="${dir}-beta"
   fi
   #echo "Major version: ${major_version}"
   #echo "Version: ${version}"
   (
     set -x
     sed -ri \
        -e 's/^(ENV VERSION) .*/\1 '"${version}"'/' \
        -e 's/^(ENV FULL_VERSION) .*/\1 '"${full_version}"'/' \
        "$dir"/{,platform/centos/}Dockerfile

        echo "$dir"/{,platform/centos/} | xargs -n 1 cp docker-entrypoint.sh
   )

done
