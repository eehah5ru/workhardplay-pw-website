#!/bin/bash

IFS=$'\n'

if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

if [ ! -f "screenings.in" ]
then
    echo "ERROR: screenings.in does not exist"
    exit 1
fi

mkdir -p "ru/$WHPH_YEAR/participants/"
mkdir -p "en/$WHPH_YEAR/participants/"

mkdir -p "ru/$WHPH_YEAR/screenings/"
mkdir -p "en/$WHPH_YEAR/screenings"

for p in `cat screenings.in`
do
    url=`cat "$p" | jq -r .url`
    echo "$url"

    participantId=`drive cat --ftype txt "$url"| stack exec generate-participant-id`

    if [ $? -ne 0 ]
    then
        echo "error generating participant id for $url"
        drive cat --ftype txt "$url"| stack exec check-screening-file
        continue
    fi

    projectId=`drive cat --ftype txt "$url"| stack exec generate-project-id`

    if [ $? -ne 0 ]
    then
        echo "error generating project-id for $url"
        drive cat --ftype txt "$url"| stack exec check-screening-file
        continue
    fi


    #
    # PARTICIPANTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-participant-file ru fromScreening > "ru/$WHPH_YEAR/participants/$participantId.md"

    # # EN
    drive cat --ftype txt "$url"| stack exec generate-participant-file en fromScreening > "en/$WHPH_YEAR/participants/$participantId.md"

    #
    # EVENTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-screening ru > "ru/$WHPH_YEAR/screenings/$projectId.md"

    # EN
    drive cat --ftype txt "$url"| stack exec generate-screening en > "en/$WHPH_YEAR/screenings/$projectId.md"
done
