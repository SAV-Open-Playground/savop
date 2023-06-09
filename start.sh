#!/usr/bin/bash
#set -ex
FOLDER=$(cd "$(dirname "$0")";pwd)
if [ -z "$1" ];then
	model_name="classic_1"
else
	model_name=$1
fi
echo ${FOLDER}
echo "start to ${model_name} net mode" 

cd ${FOLDER}
if [ ! -d "./build" ];then
  echo "create compile directory"
  mkdir ./build
else
  echo "create compile directory"
  rm -rf ./build && mkdir ./build
fi

echo "compile bird"
cd ../sav-reference-router
rm -f  "./bird" "./birdc" "./birdcl"
autoconf
./configure
make
if [ -f "./bird" ] && [ -f "./birdc" ] && [ -f "./birdcl" ];then
  echo "bird birdc birdcl are ready"
else
  echo "please check if bird birdc birdcl eixts"
  exit -1
fi
cp ./bird ${FOLDER}/build/
cp ./birdc ${FOLDER}/build/
cp ./birdcl ${FOLDER}/build/ 
cd ../sav-agent
if [ ! -d "${FOLDER}/extend_server" ];then
  mkdir ${FOLDER}/build/extend_server
fi
cp -r *.py ${FOLDER}/build/extend_server
cp -r trafficTools ${FOLDER}/build/extend_server/
cp -r ${FOLDER}/configs/conf_${model_name} ${FOLDER}/build/configs
if [ `expr match ${model_name} *.roa` -gt 0 ];then 
  cp -r ${FOLDER}/configs/conf_roa/* ${FOLDER}/build/configs/
  cd ${FOLDER}/build/configs/krill/keys && ./key.sh && cd ${FOLDER}
  if [ ! -d "${FOLDER}/build/krill" ];then
      mkdir ${FOLDER}/build/krill
      cp /root/krill/target/debug/krill ${FOLDER}/build/krill/
      cp /root/krill/target/debug/krillc ${FOLDER}/build/krill/
      cp /root/krill/target/debug/krillup ${FOLDER}/build/krill/
  fi
  cp ${FOLDER}/rpki/krill.sh  ${FOLDER}/build/krill.sh
  cp ${FOLDER}/rpki/routinator.sh  ${FOLDER}/build/routinator.sh
fi
cp ${FOLDER}/docker_compose/host_run.sh ${FOLDER}/build/host_run.sh
cp ${FOLDER}/docker_compose/docker_compose_${model_name}.yml ${FOLDER}/build/docker-compose.yml
cp -r ${FOLDER}/dockerfiles ${FOLDER}/build/
cp ${FOLDER}/topology/topo_${model_name}.sh ${FOLDER}/build/topo.sh
cp ${FOLDER}/reference_and_agent/container_run.sh  ${FOLDER}/build/container_run.sh
cp -r ${FOLDER}/network_test ${FOLDER}/build/
echo "complile bird over"
pwd
cd  ${FOLDER}/build
./host_run.sh
exit 0

