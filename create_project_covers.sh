#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m' # No Color

dest_dir="pictures/2019"

projects=`find /Volumes/qz1_after/google_drives/work.hard.play.0/РБОБ/РБОБ\ 2019/_заявки -name "*.gdoc" -exec sh -c 'echo {}' \; | grep -v "_заявки/-" | grep -v "_заявки/0 cancelled"`


for p in $projects
do
    url=`cat "$p" | jq -r .url`

    project_id=`drive cat --ftype txt "$url" | stack exec generate-project-id`

    if [ $? -ne 0 ]
    then
        echo -e "${RED} skipping $url${NC}"
        continue
    fi
    
    project_dir=$(dirname "${p}")

    echo "$project_id"

    pic=`find "$project_dir" -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" | sort | head -1`

    if [ -z "$pic" ]
    then
        echo -e "${RED}no pics for $project_id${NC}" 
        continue
    fi

    pic_file_name=$(basename -- "$pic")
    pic_ext="${pic_file_name##*.}"

    mkdir -p "$dest_dir/$project_id"
    
    cp "$pic" "$dest_dir/$project_id/$project_id-cover.$pic_ext"
done
