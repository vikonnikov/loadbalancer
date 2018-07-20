# /bin/bash

usage="Usage: ./balancer.sh [--check]
Launch docker containers with HAPROXY and NGINX and check server states.
SUDO password is required for checking servers states.
Options:
  -s, --status    Checks servers status only (utility does not affect on the containers)"

while :; do
    case $1 in
        -s|--status) check="SET"
       ;;
       -h|--help) echo "$usage"
       exit 1
       ;;
       *) break
    esac
    shift
done

if [[ $check != "SET" ]]; then
    docker-compose stop
    docker-compose up -d
    echo "Waiting for contaners will be started"
    sleep 5s
fi

echo "show servers state servers" | sudo nc -U haproxy/haproxy.sock | while read -r line ; do
    if [[ $line = *"servers"* ]]; then
	attrs=($line)
	if [[ ${attrs[5]} = "2" ]]; then
	    echo "Is RUNNING ${attrs[3]}:${attrs[4]}"
	else
	    echo "Is DOWN ${attrs[3]}:${attrs[4]}"
        fi
    fi
done
