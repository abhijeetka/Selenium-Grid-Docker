#!/bin/bash

export workspace=$1
export number=$2
docker pull www.cybage-docker-registry.com:9080/jmeterslave
docker pull www.cybage-docker-registry.com:9080/jmetermaster

echo $2;




#echo "fetching slave containers IP and storing it into variable a and variable b";
#export ip$i=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' jmeterslave1 )
#export host=dev.alm-task-manager.com

#done;



a=0
ip=127.0.0.1;
while [ $a -lt $2 ]
do
  echo $a
  docker run --name jmeterslave$a -d www.cybage-docker-registry.com:9080/jmeterslave

echo "fetching slave containers IP and storing it into variable a and variable b";

 ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' jmeterslave$a ),$ip

echo $ip
#export host=dev.alm-task-manager.com
   a=`expr $a + 1`

done



echo -e "\t\n\n\n\n\n\n\t ###############################################";
echo $ip;
echo -e "\t\n\n\n\n\n\n\t #######value of $p ########################################";

#docker run --name jmetermaster -d -v $workspace:/reports -e IP=$a,$b  www.cybage-docker-registry.com:9080/jmetermaster






