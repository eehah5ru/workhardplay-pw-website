#!/bin/bash

IFS=$'\n'

if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

if [ ! -f "projects.in" ]
then
    echo "ERROR: projects.in does not exist"
    exit 1
fi

mkdir -p "ru/$WHPH_YEAR/participants/"
mkdir -p "en/$WHPH_YEAR/participants/"

mkdir -p "ru/$WHPH_YEAR/schedule/all-days/rbob-sorting/"
mkdir -p "en/$WHPH_YEAR/schedule/all-days/rbob-sorting/"

# clean old unsorted events
rm ru/$WHPH_YEAR/schedule/all-days/rbob-sorting/*.md
rm en/$WHPH_YEAR/schedule/all-days/rbob-sorting/*.md

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
    drive cat --ftype txt "$url"| stack exec generate-participant-file ru fromProject > "ru/$WHPH_YEAR/participants/$participantId.md"

    # EN
    drive cat --ftype txt "$url"| stack exec generate-participant-file en fromProject > "en/$WHPH_YEAR/participants/$participantId.md"

    #
    # EVENTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-event-file ru > "ru/$WHPH_YEAR/schedule/all-days/rbob-sorting/$projectId.md"

    # EN
    drive cat --ftype txt "$url"| stack exec generate-event-file en > "en/$WHPH_YEAR/schedule/all-days/rbob-sorting/$projectId.md"
done
