
# Docker HPCC
### Supported tags and respective Dockerfile links
* 7 latest  [(7/Dockerfile)](https://github.com/hpcc-systems/docker-hpcc/tree/master/7/Dockerfile)
* 7-rc
* 6.4.28-1  [(6/Dockerfile)](https://github.com/hpcc-systems/docker-hpcc/tree/master/6/Dockerfile)
* 6.4.26-1
* 6.4.24-1
* 6.4.20-1


## What is HPCCSystems (HPCC)
The HPCC Systems server platform is a free, open source, massively scalable platform for big data analytics. Download the HPCC Systems server platform now and take the reins of the same core technology that LexisNexis has used for over a decade to analyze massive data sets for its customers in industry, law enforcement, government, and science.

For more information and related downloads for HPCC Systems products, please visit https://hpccsystems.com


## How to use Docker HPCC image
You can start the Docker HPCC image in interactive (-i -t) or daemon mode (-d). You must start the HPCC processes then go to ECLWatch to submit jobs, query, and explore your data with the HPCC Systems platform.

To map a docker container port to a host port.

  "-p &lt;host port&gt;:&lt;docker container port&gt;"

The default ECLWatch port is 8010.

### Ubuntu
To start Docker in interactive mode and map ECLWatch port 8010 to host 8010:
```sh
sudo docker run -t -i -p 8010:8010 hpccsystems/hpcc /bin/bash
```

To start Docker in daemon mode and map ECLWatch port 8010 to host 8020:
```sh
sudo docker run -d -p 8020:8010  hpccsystems/hpcc
```


### CentOS
To start Docker in interactive mode and map ECLWatch port 8020 to host 8010:
```sh
sudo docker run -t -i --privileged -e "container=docker" -p 8020:8010 hpccsystems/hpcc:el7 /bin/bash
```

To start Docker in daemon mode and map ECLWatch port 8010 to host 8010:
```sh
sudo docker run -d --privileged -e "container=docker"-p 8010:8010 hpccsystems/hpcc:el7
```

## How to build Docker HPCC image
You can always create your own Dockerfile to build a Docker HPCC image. We provide some pre-defined Dockerfiles and tools here.
These are for the HPCC Platform for Ubuntu 16.04 and CentOS 7. HPCC Plugins for Dockerfiles to be provided later.

### Checkout this git reposiotry
```sh
git clone https://github.com/hpcc-systems/docker-hpcc.git
```
Currently there are two release versions: Gold Release: 6/ and Release Candidate: 6-rc/. There are two product types: platform and plugins.
There are two Linux distributions: Ubuntu (Ubuntu 16.04, default) and CentOS (CentOS 7)

### Update HPCC Platform Version
Make sure the HPCC Platform version is available in HPCCSystems.com -> "Download" -> "HPCC SYSTEM PLATFORM"
Update the version with update.sh. For example, if you want to build 6.4.14-1:
```sh
./update 6.4.18-1
```
### Build
You can go to the directory of interest which contains the Dockerfile to run the build, or you can run the test-build.sh script which includes test:
```sh
sudo ./test-build.sh -v 6 -l ubuntu -p platform
```
This will build HPCC Platform 6.x  for Ubuntu 16.04.

To upload a build image to Docker Hub:
```sh
docker push <repo>:<tag>  For example: docker push hpccsystems/hpcc:latest
```
