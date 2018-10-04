#!/bin/bash -e

SCRIPT_DIR=$(dirname $0)

function usage()
{
    cat <<EOF
    Usage: $(basename $0) <options>
      <options>:
      -a: app name. The default is hpcc
      -D: HPCC home directory. The default is /opt/HPCCSystems
      -d: directory to save collecting ips. The default is /tmp/ips
      -e: number of esp nodes. The default is 1
      -n: network name. The default is <appName>_ovnet.
      -N: do not push environment.xml and restart environment.xml
      -r: number of roxie nodes
      -s: number of support nodes
      -t: number of thor nodes
      -u: update mode. It will only re-create dali/thor master environment.xml
          and environment.xml with real ip. Re-generate ansible host file,
          run updtdalienv and restart thor master.
      -x: do not retrieve cluster ips. The ips should be under directory /tmp/
          cluster ips file name <app name>_<network name.json
      -X  do not generate environmen.xml which may be created with configmgr

EOF
   exit 1
}

function create_ips_string()
{
   IPS=
   [ ! -e "$1" ] &&  return

   while read ip
   do
      ip=$(echo $ip | sed 's/[[:space:]]//g;s/;//g')
      [ -n "$ip" ] && IPS="${IPS}${ip}\\;"
   done < $1
}

function create_simple_envxml()
{
   # if there is node file it should define supportnode, espnode (optioal), roxienode and thornode
   #    use envgen to generate environment.xml

   if [ -n "${numSupport}" ]
   then
       support_nodes=${numSupport}
   elif [ -n "${SUPPORT_NODES}" ]
   then
       support_nodes=${SUPPORT_NODES}
   else
       support_nodes=1
   fi

   if [ -n "${numEsp}" ]
   then
       esp_nodes=${numEsp}
   elif [ -n "${ESP_NODES}" ]
   then
       esp_nodes=${ESP_NODES}
   else
       esp_nodes=1
   fi

   if [ -n "${numThor}" ]
   then
       thor_nodes=${numThor}
   elif [ -n "${THOR_NODES}" ]
   then
       thor_nodes=${THOR_NODES}
   else
       thor_nodes=1
   fi

   if [ -n "${numRoxie}" ]
   then
       roxie_nodes=${numRoxie}
   elif [ -n "${ROXIE_NODES}" ]
   then
       roxie_nodes=${ROXIE_NODES}
   else
       roxie_nodes=1
   fi

   create_ips_string  ${ipDir}/esp
   cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen -env ${wkDir}/${ENV_XML_FILE}   \
       -override roxie,@copyResources,true \
       -override roxie,@roxieMulticastEnabled,false \
       -override thor,@replicateOutputs,true \
       -override esp,@method,htpasswd \
       -override thor,@replicateAsync,true                 \
       -thornodes ${thor_nodes} -slavesPerNode ${slaves_per_node} \
       -espnodes ${esp_nodes} -roxienodes ${roxie_nodes} \
       -supportnodes ${support_nodes} -roxieondemand 1 \
       -ipfile ${ipDir}/node -assign_ips esp $IPS"

    echo "$cmd"
    eval "$cmd"
}

function create_complex_envxml()
{
   if [ ! -e ${ipDir}/support ]
   then
       echo "Can't find support node ip"
       exit 1
   fi

   support_nodes=$(cat ${ipDir}/support | wc -l)

   #if [ -n "${ESP_NODES}" ]
   #then
   #     esp_nodes=${ESP_NODES}
   #elif [ -e ${ipDir}/esp ]
   #then
   #     esp_nodes=0
   #else
   #     esp_nodes=1
   #fi

   if [ -n "${THOR_NODES}" ]
   then
       thor_nodes=${THOR_NODES}
   else
       thor_nodes=0
   fi

   if [ -n "${ROXIE_NODES}" ]
   then
       roxie_nodes=${ROXIE_NODES}
   else
       roxie_nodes=0
   fi

   cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env ${wkDir}/env_base.xml   \
       -thornodes ${thor_nodes} -slavesPerNode ${slaves_per_node} \
       -espnodes 1 -roxienodes ${roxie_nodes} \
       -supportnodes ${support_nodes} -roxieondemand 1 \
       -ipfile ${ipDir}/support"

   spark_entry=$(grep sparkthor ${HPCC_HOME}/componentfiles/configxml/buildset.xml)
   [ "$spark_entry" = "sparkthor" ] && cmd="$cmd -rmv spark#mysparkthor:Instance@netAddress=."

   echo "$cmd"
   eval "$cmd"


   cp   ${wkDir}/env_base.xml ${wkDir}/env_dali.xml

   if [ -e ${ipDir}/dali ]
   then
      ip=$(cat ${ipDir}/dali | sed 's/[[:space:]]//g; s/;//g')
      $SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in ${wkDir}/env_base.xml \
          -env-out ${wkDir}/env_dali.xml  -mod-node dali#mydali@ip=${ip}
   fi

   if [ -e ${ipDir}/esp ]
   then
      esp_ip=$(${HPCC_HOME}/sbin/configgen -env ${wkDir}/env_dali.xml -listall2 | grep EspProcess | cut -d',' -f3)
      cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in ${wkDir}/env_dali.xml -env-out ${wkDir}/env_esp0.xml \
           -rmv sw:esp#myesp:Instance@netAddress=${esp_ip}"
      echo "$cmd"
      eval "$cmd"
   else
      cp ${wkDir}/env_dali.xml  ${wkDir}/env_esp0.xml
   fi

   add_comp_to_envxml esp myesp ${wkDir}/env_esp0.xml ${wkDir}/env_esp.xml
   add_roxie_to_envxml ${wkDir}/env_esp.xml ${wkDir}/env_roxie.xml
   add_thor_to_envxml ${wkDir}/env_roxie.xml ${wkDir}/env_thor.xml
   add_comp_to_envxml eclcc myeclccserver ${wkDir}/env_thor.xml ${wkDir}/env_eclcc.xml
   add_comp_to_envxml scheduler myscheduler ${wkDir}/env_eclcc.xml ${wkDir}/env_scheduler.xml
   add_comp_to_envxml spark mysparkthor ${wkDir}/env_scheduler.xml ${wkDir}/env_spark.xml

   # Create topology
   create_topology ${wkDir}/env_spark.xml ${wkDir}/env_topo.xml

   # Override attributes
   cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in ${wkDir}/env_topo.xml \
       -env-out ${wkDir}/environment.xml \
       -override roxie,@copyResources,true \
       -override roxie,@roxieMulticastEnabled,false \
       -override thor,@replicateOutputs,true \
       -override esp,@method,htpasswd "

   echo "$cmd"
   eval "$cmd"
}

function add_comp_to_envxml()
{
    _comp=$1
    _default_name=$2
    env_in=$3
    env_out=$4

    # If nothing to process
    cp $env_in  $env_out

    [ ! -e ${ipDir}/${_comp}* ] && return

    index=1
    env_in_tmp=${env_in}
    env_out_tmp=${wkDir}/tmp/env_out_tmp_${index}.xml
    ls ${ipDir} | grep ${_comp}* | while read ip_file
    do
        name=$(echo ${ip_file} | cut -d '-' -s -f 2)
        [ -z "$name" ] && name=$_default_name
        cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in $env_in_tmp -env-out $env_out_tmp \
             -add-node ${_comp}#${name}@ipfile=${ipDir}/${ip_file}"

        comp_opts_var="$(echo "$ip_file" | tr 'a-z' 'A-Z' | tr '-' '_')_OPTS"
        comp_opts=${!comp_opts_var}
        [ -n "comp_opts" ] && cmd="$cmd -mod sw:${_comp}#${name}@${comp_opts}"

        inst_comp_opts_var="INSTANCE_${comp_opts_var}"
        inst_comp_opts=${!inst_comp_opts_var}
        [ -n "inst_comp_opts" ] && cmd="$cmd -mod sw:${_comp}#${name}:instance@${inst_comp_opts}"

        echo "$cmd"
        eval "$cmd"

        cp ${env_out_tmp}  ${env_out}

        index=$(expr $index \+ 1)
        env_in_tmp=${env_out_tmp}
        env_out_tmp=${wkDir}/tmp/env_out_tmp_${index}.xml
    done
}

function add_roxie_to_envxml()
{
    env_in=$1
    env_out=$2

    # If nothing to process
    cp $env_in  $env_out

    [ ! -e ${ipDir}/roxie* ] && return

    index=1
    env_in_tmp=${env_in}
    env_out_tmp=${wkDir}/tmp/env_out_tmp_${index}.xml_
    ls ${ipDir} | grep roxie* | while read ip_file
    do
        roxie_name=$(echo ${ip_file} | cut -d '-' -s -f 2)
        [ -z "$roxie_name" ] && roxie_name=myroxie

        # Add roxie nodes
        env_out_tmp=${wkDir}/tmp/env_roxie_${index}.xml
        echo "$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in $env_in_tmp -env-out ${env_out_tmp} \
             -add-node roxie#${roxie_name}@ipfile=${ipDir}/${ip_file}"
        $SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in $env_in_tmp -env-out ${env_out_tmp} \
             -add-node roxie#${roxie_name}@ipfile=${ipDir}/${ip_file}

        cp ${env_out_tmp}  ${env_out}

        index=$(expr $index \+ 1)
        env_in_tmp=${env_out_tmp}
        env_out_tmp=${wkDir}/tmp/env_out_tmp_${index}.xml
    done
}

function add_thor_to_envxml()
{
    env_in=$1
    env_out=$2

    # If nothing to process
    cp $env_in  $env_out

    [ ! -e ${ipDir}/thor-* ] && return

    index=1
    master_index=1  # In chance no master thor provided and there are multiple support nodes
    env_in_tmp=${env_in}
    env_out_tmp=${wkDir}/tmp/env_out_tmp_${index}.xml
    ls ${ipDir} | grep thor-* | while read ip_file
    do
        thor_name=$(echo ${ip_file} | cut -d '-' -s -f 2)
        [ -z "$thor_name" ] && thor_name=mythor

        # Add thor master node
        if [ -e ${ipDir}/thormaster_${thor_name} ]
        then
           master_ip=$(cat ${ipDir}/thormaster_${thor_name}* | sed 's/;//g')
        else
           master_ip=$(cat ${ipDir}/support | head -n ${master_index} | tail -n 1 | sed 's/;//g')
           let master_index="($master_index + 1)  % ${support_nodes} + 1"
        fi

        # Add thor nodes

        cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in $env_in_tmp -env-out ${env_out_tmp}"
        cmd="$cmd -add-node thor#${thor_name}:master@ip=${master_ip}:slave@ipfile=${ipDir}/${ip_file}"

        #thor_name
        node_group_name=
        found=false
        for ng in $(echo $NODE_GROUP | tr ';' ' ')
        do
           ng_name=$(echo $ng | cut -d':' -f1)
           ng_body=$(echo $ng | cut -d':' -f2)
           for thor_name2 in $(echo $ng_body | tr ',' ' ')
           do
               if [ "$thor_name2" = "$thor_name" ]
               then
                  node_group_name=$ng_name
                  found=true
                  break
               fi
           done
           [ "$found" = "true" ] && break
        done
        [ -n "$node_group_name" ] && cmd="$cmd -mod sw:thor#${thor_name}@nodeGroup=${node_group_name}"

        echo "$cmd"
        eval "$cmd"

        cp ${env_out_tmp}  ${env_out}

        index=$(expr $index \+ 1)
        env_in_tmp=${env_out_tmp}
        env_out_tmp=${wkDir}/tmp/env_out_tmp_${index}.xml
    done
}

function create_topology()
{
    env_in=$1
    env_out=$2

    # If nothing to process
    cp $env_in  $env_out
    [ -z "$TOPOLOGY" ] && return

    if [ "$TOPOLOGY" = "default" ]
    then
        cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in $env_in -env-out ${env_out} -add-topology default"
        echo "$cmd"
        eval "$cmd"
        return
    fi

    env_in_tmp=${env_in}
    index=1
    env_out_tmp=${wkDir}/tmp/env_topo_tmp_${index}.xml
    for topology in $(echo $TOPOLOGY | tr '#' ' ')
    do
       #echo ""
       topo_name=$(echo $topology | cut -d'%' -f1)
       #echo "Topology name $topo_name"
       topo_body=$(echo $topology | cut -d'%' -f2)

       for cluster in $(echo $topo_body | tr ';' ' ')
       do
          cluster_name=$(echo $cluster | cut -d':' -f1)
          cluster_body=$(echo $cluster | cut -d':' -f2)
          #echo "  cluster name:  $cluster_name"

          cmd="$SUDOCMD ${HPCC_HOME}/sbin/envgen2 -env-in $env_in_tmp -env-out ${env_out_tmp} -add-topology ${topo_name}:cluster@name=${cluster_name}"
          for process in $(echo $cluster_body | tr ',' ' ')
          do
              process_tag=$(echo $process | cut -d'@' -f1)
              process_name=$(echo $process | cut -d'@' -f2)
              #echo "     process: $process_tag name: $process_name"
              cmd="${cmd}:${process_tag}@process=${process_name}"
          done

          echo "$cmd"
          eval "$cmd"

          cp ${env_out_tmp}  ${env_out}

          index=$(expr $index \+ 1)
          env_in_tmp=${env_out_tmp}
          env_out_tmp=${wkDir}/tmp/env_topo_tmp_${index}.xml
       done
    done
}

function create_envxml()
{

   if [ -e ${ipDir}/node ]
   then
       create_simple_envxml
   else
       create_complex_envxml
   fi
}

function collect_ips()
{
  mkdir -p $ipDir
  trials=3
  while [ $trials -gt 0 ]
  do

       [ $notGetIps -eq 0 ] &&  ${SCRIPT_DIR}/get_ips.sh ${networkName}
       ${SCRIPT_DIR}/ip/CollectIPs.py -d ${ipDir} -i /tmp/${cluster_ips}
       [ $? -eq 0 ] && break
       trials=$(expr $trials \- 1)
       sleep 5
  done
}

function adjust_node_type_for_ansible()
{
    [ -d ${ipDir2} ] && rm -rf ${ipDir2}
    mkdir -p ${ipDir2}

    found_dali=false
    cluster_node_types=$(cat ${wkDir}/hpcc.conf | grep -i "cluster_node_types" | cut -d'=' -f2)
    for node_type in $(echo ${cluster_node_types} | sed 's/,/ /g')
    do
         [ "$node_type" = "dali" ] && found_dali=true
         node_type2=$(echo $node_type | cut -d'-' -s -f1);
         [ -z "$node_type2" ] &&  node_type2=$node_type
         cluster_name=$(echo $node_type | cut -d'-' -s -f2);
         [ -n "$cluster_name" ] && node_type2=${node_type2}-${cluster_name}
         cp ${ipDir}/${node_type} ${ipDir2}/${node_type2}
    done

    [ "${found_dali}" = "true" ] && return  || :
    [ -n "$cluster_node_types" ] && cluster_node_types="${cluster_node_types}," || :
    cluster_node_types="${cluster_node_types}dali"
    echo "cluster_node_types=${cluster_node_types}" > ${wkDir}/hpcc.conf

    # Find dali ip
    dali_ip=$($SUDOCMD /opt/HPCCSystems/sbin/configgen -env ${clusterConfigDir}/environment.xml -listall -t dali | cut -d',' -f3)
    echo $dali_ip > ${ipDir2}/dali

    if [ -e ${ipDirs2}/node ]
    then
         node_to_process=node
    else
         node_to_process=support
    fi
    cat ${ipDir2}/${node_to_process} | grep -v ${dali_ip} > ${wkDir}/node_tmp || :

    mv ${wkDir}/node_tmp ${ipDir2}/${node_to_process}
    non_dali_nodes=$(cat ${ipDir2}/${node_to_process} | wc -l)
    if [ ${non_dali_nodes} -eq 0 ]
    then
        rm -rf ${ipDir2}/${node_to_process}
    fi
    hpcc_config=$(ls ${ipDir2} | grep -v "admin" | tr '\n' ',')
    echo "cluster_node_types=${hpcc_config%,}" > ${wkDir}/hpcc.conf
}

function setup_ansible_hosts()
{
  $SUDOCMD ${SCRIPT_DIR}/ansible/setup.sh -d ${ipDir2} -c ${wkDir}/hpcc.conf
  export ANSIBLE_HOST_KEY_CHECKING=False
}

#------------------------------------------
# Need root or sudo
#
SUDOCMD=
[ $(id -u) -ne 0 ] && SUDOCMD=sudo


#------------------------------------------
# LOG

#
LOG_DIR=~/tmp/log/hpcc-tools
mkdir -p $LOG_DIR
LONG_DATE=$(date "+%Y-%m-%d_%H-%M-%S")
LOG_FILE=${LOG_DIR}/config_hpcc_${LONG_DATE}.log
touch ${LOG_FILE}
exec 2>$LOG_FILE
set -x

update=0
appName=hpcc
ipDir=~/tmp/ips
ipDir2=~/tmp/ips2
wkDir=~/tmp/work
notPush=0
notGetIps=0
notCreateEnv=0
HPCC_HOME=/opt/HPCCSystems
clusterConfigDir=/etc/HPCCSystems/source
numSupport=
numEsp=
numRoxie=
numThor=
networkName=${appName}_ovnet

[ ! -d ${wkDir} ] && mkdir -p ${wkDir}

while getopts "*a:d:D:e:hn:N:r:s:t:uxX" arg
do
   case $arg in
      a) appName=${OPTARG}
         ;;
      d) ipDir=${OPTARG}
         ;;
      D) HPCC_HOME=${OPTARG}
         ;;
      e) numEsp=${OPTARG}
         ;;
      h) usage
         ;;
      n) networkName=${OPTARG}
        ;;
      N) notPush=1
        ;;
      r) numRoxie=${OPTARG}
         ;;
      s) numSupport=${OPTARG}
         ;;
      t) numThor=${OPTARG}
         ;;
      u) update=1
        ;;
      x) notGetIps=1
        ;;
      X) notCreateEnv=1
        ;;
      ?)
         echo "Unknown option $OPTARG"
         usage
         ;;
   esac
done

echo "update mode: $update"
#----------------------------------------o
# Start sshd
#
ps -efa | grep -v sshd |  grep -q sshd ||  $SUDOCMD mkdir -p /var/run/sshd; $SUDOCMD  /usr/sbin/sshd -D &

#------------------------------------------
# Collect containers' ips
#
cluster_ips=${networkName}.json
[ -d ${ipDir} ] && rm -rf ${ipDir}
collect_ips

#------------------------------------------
# handle update
if [ $update  -eq 1 ] && [ -d ${wkDir}/ips ]
then
    diff ${ipDir} ${wkDir}/ips > /tmp/ips.diff
    ips_diff_size=$(ls -s /tmp/ips_diff.txt | cut -d' ' -f1)
    [ $ips_diff_size -eq 0 ] && exit 0
fi

#------------------------------------------
# Create HPCC components file
#
hpcc_config=$(ls ${ipDir} | grep -v "admin" | tr '\n' ',')
echo "cluster_node_types=${hpcc_config%,}" > ${wkDir}/hpcc.conf

#backup
[ -d ${wkDir}/ips ] && rm -rf ${wkDir}/ips
cp -r ${ipDir} ${wkDir}/
ENV_XML_FILE=environment.xml

mkdir -p ${wkDir}/tmp

#------------------------------------------
# Generate environment.xml
#
#set_vars_for_envgen2
if [ $notCreateEnv -eq 0 ]
then
   slaves_per_node=1
   [ -n "$SLAVES_PER_NODE" ] && slaves_per_node=${SLAVES_PER_NODE}
   create_envxml
   mkdir -p $clusterConfigDir
   cp ${wkDir}/environment.xml  ${clusterConfigDir}/
fi

#------------------------------------------
# Setup Ansible hosts
#
adjust_node_type_for_ansible
setup_ansible_hosts
dali_ip=$(cat /etc/ansible/ips/dali)

[ $notPush -eq 1 ] && exit 0

#  set_hpcc_data_owner
echo "Stop HPCC Cluster"
${SCRIPT_DIR}/stop_hpcc.sh

echo "Push environment.xml to HPCC Cluster"
${SCRIPT_DIR}/push_env.sh

echo "Start HPCC Cluster"
${SCRIPT_DIR}/start_hpcc.sh

set +x
echo "$SUDOCMD /opt/HPCCSystems/sbin/configgen -env ${clusterConfigDir}/environment.xml -listall2"
$SUDOCMD /opt/HPCCSystems/sbin/configgen -env ${clusterConfigDir}/environment.xml -listall2
echo "HPCC cluster configuration is done."
