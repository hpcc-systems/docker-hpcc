# HPCC Systems Platform Community Version
  platform/
  -  ce/base/&lt;version&gt;/Dockerfile: HPCC Systems Platform Community version prequisites (Ubuntu 18.04)
     Docker Hub:  hpccsystems/hpcc-base
  -  ce/Dockerfile  HPCC Systems Platform Community version Docker build file with version as input argument.
     Docker Hub:  hpccsystems/platform
  -  ln/base/&lt;version&gt;/Dockerfile: HPCC Systems Platform Internal version prequisites (CentOS 7)
  -  ln/Dockerfile HPCC Systems Platform Internal with Plugins Docker build file with version as input argument

  clienttools/
  -  ce/Dockerfile: HPCC Systems Clienttools Community Docker version build file with version as input argument
     Docker Hub: hpccsystems/clienttools
  -  ln/Dockerfile: HPCC Systems Clienttools Internal version Docker build file with version as input argument

  plugins/
  -  ce/Dockerfile: HPCC Systems Plugins Community version Docker build file (based Platform Docker image) with version as input argument

  spark/

## How to buid
Create HPCC Systems Platform Docker image :
For example:
```console
sudo docker build -t hpccsystems/platform:7.4.8-1 --build-arg version=7.4.8-1 .
```

# Development and custom Build
  dev/&lt;version&gt;
    &lt;bionic|disco|eoan|el7|gcc7|gcc8|gcc9&gt;/
  -   base/&lt;verson&gt;/Dockerfile: HPCC Systems Platform community version prequisites
  -   bldsvr/Dockerfile: Build Server Docker build file
  -   platform/&lt;ce|ln&gt;/Dockerfile: Docker build file for compiling and building HPCC Systems Platform image

## How to build
  The compiling and building Docker build file has "ARG" for various input parameter.

Build master branch:
```console
sudo docker build -t hpccsystems/platform:master .
```

Build branch or tag, for example community_7.4.10-rc1:
```console
sudo docker build -t hpccsystems/platform:7.4.10-rc1 --build-arg branch=community_7.4.10-rc1 .
```

Build your own repo and branch:
```console
sudo docker build -t <your docker hub name>/platform:<your branch> --build-arg owner=<your github account> --build-arg branch=<your branch> .
```

Build a private repo:
```console
sudo docker build -t  <your docker hub name>/platform:<branch> --build-arg owner=<owner of repo> --build-arg branch=<branch>--build-arg user=<username> --build-arg password=<password> .
```
