#!/bin/bash

IFS=$'\n'

for p in `cat screenings.in`
do
    url=`cat "$p" | jq -r .url`
    echo "$url"
    drive cat --ftype txt "$url"| stack exec check-screening-file
done
