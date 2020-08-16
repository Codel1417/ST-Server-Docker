#!/usr/bin/bash
set -e

CONFIG_PATH=/data/options.json

PREMIUM=$(jq --raw-output '.Premium Tick Rate // empty' $CONFIG_PATH)
TOKEN=$(jq --raw-output '.Password // empty' $CONFIG_PATH)
NAME=$(jq --raw-output '.Server Name // empty' $CONFIG_PATH)

COMMAND="./skyrim_server_linux -name $NAME"

if [ PREMIUM = "true" ]
then
    COMMAND=$COMMAND -premium
fi
if [ NAME != "" ]
then
    COMMAND=$COMMAND -name $NAME
fi
if [ TOKEN != "" ]
then
    COMMAND=$COMMAND -name $TOKEN
fi

eval $COMMAND