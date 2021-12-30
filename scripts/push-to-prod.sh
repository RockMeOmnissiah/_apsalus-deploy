#!/bin/bash

deploy_host=127.0.0.1
deploy_port=2222

deploy_user=omnissiah
deploy_dest=/home/omnissiah/Apsalus

dev_use_local_app_server="Y"

run_mongo_setup="N"
run_nginx_letsencrypt_setup="N"

run_node_setup="Y"

project_dirs="/YOUR_PROJECT_PATH/Apsalus/apsalus-app-next /YOUR_PROJECT_PATH/Apsalus/_apsalus-deploy"
project_dirs_array=($project_dirs)

if ! [ -x "$(command -v docker compose)" ]; then
  echo 'Error: docker compose is not installed.' >&2
  exit 1
fi

echo -e "\nTaking down remote docker...\n"
ssh -p $deploy_port $deploy_user@$deploy_host /bin/bash <<EOSSH1

  cd $deploy_dest/_apsalus-deploy
  docker-compose down
  exit
EOSSH1

echo -e "\nCopying project files...\n"
rsync -avz -e "ssh -p $deploy_port" $project_dirs $deploy_user@$deploy_host:$deploy_dest

echo -e "\nStarting remote docker...\n"
ssh -p $deploy_port $deploy_user@$deploy_host /bin/bash <<EOSSH2

  cd $deploy_dest/_apsalus-deploy
  docker-compose up -d --build
  exit
EOSSH2

sleep 5

if [ "$run_mongo_setup" == "Y" ] || [ "$run_mongo_setup" == "y" ]; then
  echo -e "\nRunning Mongo Setup script...\n"
  ssh -p $deploy_port $deploy_user@$deploy_host /bin/bash <<EOSSH3
    cd $deploy_dest/_apsalus-deploy
    docker exec -i mongo-0.mongo /bin/sh /scripts/mongo-setup.sh
    exit
EOSSH3
fi

if [ "$run_nginx_letsencrypt_setup" == "Y" ] || [ "$run_nginx_letsencrypt_setup" == "y" ]; then
  echo -e "\nRunning Nginx LetsEncrypt Setup script...\n"
  ssh -p $deploy_port $deploy_user@$deploy_host /bin/bash <<EOSSH4
    cd $deploy_dest/_apsalus-deploy
    docker exec -i nginx /bin/sh /scripts/nginx-letsEncrypt-setup.sh
    exit
EOSSH4
fi

if [ "$run_node_setup" == "Y" ] || [ "$run_node_setup" == "y" ]; then
  if [ "$dev_use_local_app_server" == "Y" ] || [ "$dev_use_local_app_server" == "y" ]; then
    echo -e "\nRUN_NODE_SETUP + DEV_USE_LOCAL_APP_SERVER ??? >>> Skipping the node setup script...\n"
  else
    echo -e "\nRunning Node Setup script...\n"
      ssh -p $deploy_port $deploy_user@$deploy_host /bin/bash <<EOSSH5
        cd $deploy_dest/_apsalus-deploy
        docker exec -i node /bin/sh /scripts/node-setup.sh
        exit
EOSSH5
  fi
fi

if [ "$dev_use_local_app_server" == "Y" ] || [ "$dev_use_local_app_server" == "y" ]; then
  echo -e "\nDEV_USE_LOCAL_APP_SERVER >>> Stopping remove node + nginx...\n"
  ssh -p $deploy_port $deploy_user@$deploy_host /bin/bash <<EOSSH7
    cd $deploy_dest/_apsalus-deploy
    docker-compose stop nginx
    docker-compose stop node
    exit
EOSSH7
fi
