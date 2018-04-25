#!/usr/bin/env bash
#
# Run a test build for all images.

source functions

usage()
{
  echo ""
  echo "Usage: test-build.sh -v <versions list> -p <package list> -l <linux ariant>"
  echo "   -v major version list, comma delimited"
  echo "   -p package list, comma delimited. The default is platform."
  echo "   -l linux variant, comma delimited. The default is ubuntu. The other choice is centos"
  echo ""
  exit 1
}


function build()
{
  local version
  local tag
  local variant
  local package
  local path
  version="$1"; shift
  package="$1"; shift
  variant="$1"; shift


  if [ "$variant" = "ubuntu" ]
  then
    if  [ "$package" = "platform" ]
    then
       tag="latest"
       path="$version"
    else
       full_tag="$package"
       path="$version/$package"
    fi
  else
    if [ "$package" = "platform" ]
    then
       tag=${distro_tag["$variant"]}
       path="$version/$package/$variant"
    else
       tag=${package}-${distro_tag["$variant"]}
       path="$version/$package/$variant"
    fi
  fi


  echo
  echo
  info "Building $tag ..."

  info "Docker build -t hpccsystems/hpcc:$tag $path"
  logfile=/tmp/docker_hpcc_${version}_${package}_${variant}.log
  info "Log file: $logfile"
  if ! docker build -t "hpccsystems/hpcc:$tag" "$path" > $logfile 2>&1

  then
    fatal "Build of $tag failed!. Log file: $logfile"
  else
    info "Building succeeded!"
  fi

  echo ""
  info "Testing hpcc:$tag"
  if [ "$variant" = "centos" ]
  then
      info "docker run --rm --privileged -e \"container=docker\" -v \"$PWD/test-${package}.sh:/usr/local/bin/test.sh\" hpccsystems/hpcc:${tag} test.sh"
      docker run --rm --privileged -e "container=docker" -v "$PWD/test-${package}.sh:/usr/local/bin/test.sh" hpccsystems/hpcc:${tag} test.sh
  else
      info "docker run --rm -v \"$PWD/test-${package}.sh:/usr/local/bin/test.sh\" hpccsystems/hpcc:${tag} test.sh"
      docker run --rm -v "$PWD/test-${package}.sh:/usr/local/bin/test.sh" hpccsystems/hpcc:${tag} test.sh
  fi
  echo ""

}

versions=("6")
packages=("platform")
variants=("ubuntu")

distro_tag["centos"]="el7"

while getopts "*l:p:v:" arg
do
  case "$arg" in
       l) IFS=',' read -ra variants <<< "${OPTARG}"
          ;;
       p) IFS=',' read -ra packages <<< "${OPTARG}"
          ;;
       v) IFS=',' read -ra versions <<< "${OPTARG}"
          ;;
       ?) usage
          ;;
  esac
done


[ ${#variants[@]} -eq 0 ] &&  variants=("ubuntu")
[ ${#packages[@]} -eq 0 ] &&  packages=("platform")

for version in "${versions[@]}"
do
  for package in "${packages[@]}"
  do
    for variant in "${variants[@]}"
    do
      build "$version" "$package" "$variant"
    done
  done
done
