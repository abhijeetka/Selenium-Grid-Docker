#!/usr/bin/env bash

DEBUG=''

if [ -n "$1" ] && [ $1 == 'debug' ]; then
  DEBUG='-debug'
fi

echo Building test container image
docker build -t selenium/test:local ./Test

echo 'Starting Selenium Hub Container...'
HUB=$(docker run -d selenium/hub:2.47.1)
HUB_NAME=$(docker inspect -f '{{ .Name  }}' $HUB | sed s:/::)
echo 'Waiting for Hub to come online...'
docker logs -f $HUB &
sleep 2


echo 'Starting Selenium Chrome node...'
NODE_CHROME=$(docker run -d --link $HUB_NAME:hub  selenium/node-chrome$DEBUG:2.47.1)
echo 'Starting Selenium Firefox node...'
NODE_FIREFOX=$(docker run -d --link $HUB_NAME:hub selenium/node-firefox$DEBUG:2.47.1)
docker logs -f $NODE_CHROME &
docker logs -f $NODE_FIREFOX &
echo 'Waiting for nodes to register and come online...'
sleep 8s



echo 'creating empty log files for nodes and hub'
#creating files to store logs
touch node_firefox.log node_chrome.log hub.log


echo "*************************************calling function firefox*****************************************"
echo 'calling function test_node_firefox'
 test_node_firefox
 {
  BROWSER=firefox
  echo Running $BROWSER test...
  TEST_CMD="node smoke-$BROWSER.js"
# docker run -it --link $HUB_NAME:hub -e TEST_CMD="$TEST_CMD" selenium/test:local
  docker run -d --link $HUB_NAME:hub -e TEST_CMD="$TEST_CMD" selenium/test:local
 
 STATUS=$? 
  TEST_CONTAINER_firefox=$(docker ps -aq | head -1)

  if [ ! $STATUS = 0 ]; then
    echo Failed
    exit 1
  fi

echo 'creating test-local-firefix log file '
     touch test_local_firefox.log
     echo $TEST_CONTAINER_firefox
 


    echo "**************logs of TEST_CONTAINER_firefox**************"
    docker logs -f $TEST_CONTAINER_firefox | tee test_local_firefox.log
    echo "**********************************************************"


     echo Removing the test container firefox
     docker stop $TEST_CONTAINER_firefox
     docker rm $TEST_CONTAINER_firefox

}

echo '**************************************end of function firefox****************************************'



echo '***********************************calling function chrome*****************************************'





echo 'calling function test_node_chrome'
test_node_chrome
 {
  BROWSER=chrome
  echo Running $BROWSER test...
  TEST_CMD="node smoke-$BROWSER.js"
#  docker run -it --link $HUB_NAME:hub -e TEST_CMD="$TEST_CMD" selenium/test:local
  docker run -d --link $HUB_NAME:hub -e TEST_CMD="$TEST_CMD" selenium/test:local
  STATUS=$?
  TEST_CONTAINER_chrome=$(docker ps -aq | head -1)

  if [ ! $STATUS = 0 ]; then
    echo Failed
    echo '*****************'
    exit 1
  fi

     touch test_local_chrome.log

    echo "**************logs of TEST_CONTAINER_firefox**************"
    docker logs -f $TEST_CONTAINER_chrome | tee test_local_chrome.log
    echo "**********************************************************"

    echo Removing the test container chrome
    docker stop $TEST_CONTAINER_chrome
    docker rm $TEST_CONTAINER_chrome


        }
echo "*******************************end of function chrome*******************************************"



echo '***************************************stopping node *******************************************'


#test_node_chrome $DEBUG
#test_node_firefox $DEBUG



  docker logs $NODE_CHROME | tee node_chrome.log
  echo Tearing down Selenium Chrome Node container
  docker stop $NODE_CHROME
  docker rm $NODE_CHROME


  docker logs $NODE_FIREFOX | tee node_firefox.log
  echo Tearing down Selenium Firefox Node container
  docker stop $NODE_FIREFOX 
  docker rm $NODE_FIREFOX



  docker logs $HUB | tee hub.log
  echo 'At last removing hub'
  docker stop $HUB
  docker rm $HUB


echo Done
echo '*******************************************end of script******************************************'
