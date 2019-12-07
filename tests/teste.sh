#!/bin/bash

result=$(which curl)
if [ -z $result ]
then
	echo "Necessário ter o comando curl no sistema operacional. Tente apt-get install curl"
	exit 1
fi

result=$(which jq)
if [ -z $result ]
then
	echo "Necessário ter o comando jq no sistema operacional. Tente apt-get install jq"
	exit 1
fi


IP=$1
PORT=3000

if [ -z $IP ]
then
	IP="127.0.0.1"
fi
echo "========"
echo "Testando endpoints em: $IP:$PORT"
echo "========"

RESPONSE=""
BODY=""
STATUS=""
NOTA=0

calculaNota() {
	merece_nota=true
	for i in $@; do
		if $merece_nota && $i 
		then
			merece_nota=true
		else
			merece_nota=false
		fi
	done

	if $merece_nota
	then
		NOTA=$((NOTA+1))
	fi
	printf "NOTA $NOTA \n\n"
}

get() {
	endpoint=$1
	RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" http://$IP:$PORT$endpoint -X GET -H "Content-Type: application/json")
	BODY=$(echo $RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
	STATUS=$(echo $RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
	echo "@GET $endpoint $STATUS $BODY"
}

post() {
	endpoint=$1
	json=$2
	RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" http://$IP:$PORT$endpoint -X POST -H "Content-Type: application/json" --data "@$json")
	BODY=$(echo $RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
	STATUS=$(echo $RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
	echo "@POST $endpoint $STATUS $BODY"
}

hasBody() {
	attribute=".$1"
	expect=$2
	RESULT=$(echo $BODY | jq -r $attribute)
	if [[ $RESULT == $expect ]]
	then
		echo true
	else
		echo false
	fi
}

hasStatus() {
	expect=$1
	if [ $STATUS == $expect ]
	then
		echo true
	else
		echo false
	fi
}

get "/"
calculaNota $(hasBody "message" "ok")

post "/login" "login_incorreto.json"
calculaNota $(hasStatus 401) $(hasBody "message" "Error in username or password")

# echo "@GET /"
# RESULT=$(curl -s http://$IP:$PORT/ -X GET -H "Content-Type: application/json" | jq -r '.message')

# if [ $RESULT == "ok" ]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"


# STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" http://$IP:$PORT/login -X POST -H "Content-Type: application/json" --data "@login_incorreto.json")
# MESSAGE=$(curl -s http://$IP:$PORT/login -X POST -H "Content-Type: application/json" --data "@login_incorreto.json" | jq -r '.message')
# printf "@POST /login -- $STATUS :: $MESSAGE\n"
# if [[ ( $STATUS == 401 && $MESSAGE == "Error in username or password" ) ]]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"


# TOKEN=$(curl -s http://$IP:$PORT/login -X POST -H "Content-Type: application/json" --data "@login.json" | jq -r '.token')
# printf "@POST /login -- $TOKEN\n"
# if [ ! -z $TOKEN ]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"

# STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" http://$IP:$PORT/tasks -X POST -H "Content-Type: application/json" -H "x-access-token: $TOKEN" --data "@new_task.json")
# TASK_ID=$(curl -s http://$IP:$PORT/tasks -X POST -H "Content-Type: application/json" -H "x-access-token: $TOKEN" --data "@new_task.json" | jq -r '.id')
# printf "@POST /tasks -- $STATUS :: $TASK_ID\n"
# if [[ ( $STATUS == 201 && $TASK_ID != "" ) ]]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"

# STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" http://$IP:$PORT/tasks -X POST -H "Content-Type: application/json" -H "x-access-token: $TOKEN" --data "@new_task dog.json")
# TASK_ID_DOG=$(curl -s http://$IP:$PORT/tasks -X POST -H "Content-Type: application/json" -H "x-access-token: $TOKEN" --data "@new_task dog.json" | jq -r '.id')
# printf "@POST /tasks -- $STATUS :: $TASK_ID_DOG\n"
# if [[ ( $STATUS == 201 && $TASK_ID_DOG != "" ) ]]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"


# RESULT=$(curl -s http://$IP:$PORT/tasks -X GET -H "Content-Type: application/json" -H "x-access-token: $TOKEN")
# printf "@GET /tasks -- $RESULT\n"
# if [[ ( $RESULT == *"$TASK_ID"* && $RESULT == *"$TASK_ID_DOG"* ) ]]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"

exit 0
	

