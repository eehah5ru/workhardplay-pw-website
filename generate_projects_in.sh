#!/bin/bash

IFS=$'\n'

if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

lines=`find /Volumes/qz1_after/google_drives/work.hard.play.0/РБОБ/РБОБ\ $WHPH_YEAR/_заявки \( -name "*.gdoc" ! -name "-*.gdoc" \) -exec sh -c 'echo {}' \;`

# remove not completed
lines=`echo "$lines" | grep -v "_заявки/-"`

# remove completed
lines=`echo "$lines" | grep -v "_заявки/+"`

# remove instructions
lines=`echo "$lines" | grep -v "_заявки/\~"`

# remove cancelled
lines=`echo "$lines" | grep -v "_заявки/0 cancelled"`

echo "$lines" > projects.in
