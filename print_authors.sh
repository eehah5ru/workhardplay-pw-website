#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m' # No Color

dest_dir="pictures/2019"

projects=`find /Volumes/qz1_after/google_drives/work.hard.play.0/РБОБ/РБОБ\ 2019/_заявки -name "*.gdoc" -exec sh -c 'echo {}' \; | grep -v "_заявки/-" | grep -v "_заявки/0 cancelled"`


for p in $projects
do
    url=`cat "$p" | jq -r .url`

    author=`drive cat --ftype txt "$url" | stack exec get-author $1`

    if [ $? -ne 0 ]
    then
        echo -e "${RED} skipping $url${NC}"
        continue
    fi

    echo "$author"
done
