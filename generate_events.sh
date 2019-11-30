#!/bin/bash

IFS=$'\n'


mkdir -p "ru/2019/participants/"
mkdir -p "en/2019/participants/"

mkdir -p "ru/2019/schedule/all-days/rbob-sorting/"
mkdir -p "en/2019/schedule/all-days/rbob-sorting/"

for p in `cat projects.in`
do
    url=`cat "$p" | jq -r .url`
    echo "$url"

    participantId=`drive cat --ftype txt "$url"| stack exec generate-participant-id`

    if [ $? -ne 0 ]
    then
        echo "error generating participant id for $url"
        drive cat --ftype txt "$url"| stack exec check-project-file
        continue
    fi

    projectId=`drive cat --ftype txt "$url"| stack exec generate-project-id`

    if [ $? -ne 0 ]
    then
        echo "error generating project-id for $url"
        drive cat --ftype txt "$url"| stack exec check-project-file
        continue
    fi


    #
    # PARTICIPANTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-participant-file ru > "ru/2019/participants/$participantId.md"

    # EN
    drive cat --ftype txt "$url"| stack exec generate-participant-file en > "en/2019/participants/$participantId.md"

    #
    # EVENTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-event-file ru > "ru/2019/schedule/all-days/rbob-sorting/$projectId.md"

    # EN
    drive cat --ftype txt "$url"| stack exec generate-event-file en > "en/2019/schedule/all-days/rbob-sorting/$projectId.md"
done
