#!/usr/bin/env bash

if [ "$1" != "start" ] && [ "$1" != "restart" ] && [ "$1" != "stop" ]; then
	echo "Options are start, stop, restart"
	exit 1
fi

if [ "$1" == "stop" ] || [ "$1" == "restart" ]; then
	curl -H "Content-Type:application/json" -X DELETE http://master.mesos:8080/v2/apps/elk
fi

if [ "$1" == "start" ] || [ "$1" == "restart" ]; then

cat >/tmp/elk_run.json <<EOL
{
	"id": "/elk",
	"cpus": 0.2,
	"mem": 512.0,
	"instances": 1,
	"constraints": [
		[ "node_type", "LIKE", "master" ]
	],
	"container": {
		"type": "DOCKER",
		"docker": {
			"image": "appsoma/elk:latest",
			"network": "HOST",
		}
	}
}
EOL

curl -H "Content-Type:application/json" -X POST --data @/tmp/elk_run.json http://master.mesos:8080/v2/apps

fi
echo