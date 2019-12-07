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
	token=$2
	RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" http://$IP:$PORT$endpoint -X GET -H "Content-Type: application/json" -H "x-access-token: $token")
	BODY=$(echo $RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
	STATUS=$(echo $RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
	echo "@GET $endpoint $STATUS $BODY"
}

post() {
	endpoint=$1
	json=$2
	token=$3
	RESPONSE=$(curl -s -w "HTTPSTATUS:%{http_code}" http://$IP:$PORT$endpoint -X POST -H "Content-Type: application/json" -H "x-access-token: $token" --data "@$json")
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

getBodyAttribute() {
	attribute=".$1"
	echo $(echo $BODY | jq -r $attribute)
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

# get "/"
# calculaNota $(hasBody "message" "ok")

# post "/login" "login_incorreto.json"
# calculaNota $(hasStatus 401) $(hasBody "message" "Error in username or password")

# post "/login" "login.json"
# token=$(getBodyAttribute "token")
# calculaNota $(hasStatus 200) $(hasBody "token" "$token")

# post "/tasks" "new_task.json" $token
# id_task=$(getBodyAttribute "id")
# calculaNota $(hasStatus 201) $(hasBody "id" "$id_task")

# post "/tasks" "new_task dog.json" $token
# id_task_dog=$(getBodyAttribute "id")
# calculaNota $(hasStatus 201) $(hasBody "id" "$id_task_dog")

get "/tasks" $token
calculaNota $(hasBody "id" "$id_task_dog")

# RESULT=$(curl -s http://$IP:$PORT/tasks -X GET -H "Content-Type: application/json" -H "x-access-token: $TOKEN")
# printf "@GET /tasks -- $RESULT\n"
# if [[ ( $RESULT == *"$TASK_ID"* && $RESULT == *"$TASK_ID_DOG"* ) ]]
# then
# 	NOTA=$((NOTA+1))
# fi
# printf "NOTA $NOTA \n\n"

exit 0
	

