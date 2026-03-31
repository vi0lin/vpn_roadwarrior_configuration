#!/usr/bin/bash

execute_ssh() {
  SERVER="$1"
  user_example="root"
  ip_example="192.168.1.2"
  if [[ $SERVER == "a" ]]; then
    word="Public"
    # ip_example="46.24.155.158"
  else
    word="Local"
    # ip_example="192.168.0.28"
  fi
  read -p "$word IP [$ip_example]: " ip
  ip=${ip:-$ip_example}
  read -p "username [$user_example]: " user
  user=${user:-$user_example}
  read -p "$user@$ip - [ password ]: " password
  echo $ip $user $password

  ssh $user@$ip 'bash -s' < server_$SERVER.sh
}

execute_ssh a
execute_ssh b
