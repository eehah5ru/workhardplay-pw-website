#!/bin/bash

IFS=$'\n'

if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

if [ ! -f "instructions.in" ]
then
    echo "ERROR: instructions.in does not exist"
    exit 1
fi

mkdir -p "ru/$WHPH_YEAR/participants/"
mkdir -p "en/$WHPH_YEAR/participants/"

mkdir -p "ru/$WHPH_YEAR/instructions/"
mkdir -p "en/$WHPH_YEAR/instructions"

for p in `cat instructions.in`
do
    url=`cat "$p" | jq -r .url`
    echo "$url"

    participantId=`drive cat --ftype txt "$url"| stack exec generate-participant-id`

    if [ $? -ne 0 ]
    then
        echo "error generating participant id for $url"
        drive cat --ftype txt "$url"| stack exec check-instruction-file
        continue
    fi

    projectId=`drive cat --ftype txt "$url"| stack exec generate-project-id`

    if [ $? -ne 0 ]
    then
        echo "error generating project-id for $url"
        drive cat --ftype txt "$url"| stack exec check-instruction-file
        continue
    fi


    #
    # PARTICIPANTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-participant-file ru fromInstruction > "ru/$WHPH_YEAR/participants/$participantId.md"

    # # EN
    drive cat --ftype txt "$url"| stack exec generate-participant-file en fromInstruction > "en/$WHPH_YEAR/participants/$participantId.md"

    #
    # EVENTS
    #

    # RU
    drive cat --ftype txt "$url"| stack exec generate-instruction ru > "ru/$WHPH_YEAR/instructions/$projectId.md"

    # EN
    drive cat --ftype txt "$url"| stack exec generate-instruction en > "en/$WHPH_YEAR/instructions/$projectId.md"
done
