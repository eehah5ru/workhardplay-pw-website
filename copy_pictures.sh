#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color



if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

dest_dir="pictures-high/$WHPH_YEAR"

projects=`find /Volumes/qz1_after/google_drives/work.hard.play.0/РБОБ/РБОБ\ $WHPH_YEAR/_заявки \( -name "*.gdoc" ! -name "-*.gdoc" \) -exec sh -c 'echo {}' \; | grep -v "_заявки/0 cancelled"`

for p in ${projects}
do
    url=`cat "$p" | jq -r .url`

    project_id=`drive cat --ftype txt "$url" | stack exec generate-project-id`

    if [ $? -ne 0 ]
    then
        echo "error generating project-id for $url"
        continue
    fi
    
    project_dir=$(dirname "${p}")

    echo -e "${GREEN}copying pics for: $project_id${NC}"

    #
    # generating cover
    #

    # all pics
    ALL_PICS=`find "$project_dir" -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.gif" | sort`

    # cover pic
    COVER_PIC=`echo -e "$ALL_PICS" | grep "cover" | sort | head -1`

    # rest of pics
    PICS=`echo -e "$ALL_PICS" | grep -v "cover" | sort`

    if [[ ( -z ${COVER_PIC} ) || ( ${COVER_PIC} == 0 ) ]]
    then
        echo -e "${YELLOW}no cover pic for $project_id. taking first one as cover.${NC}" 
        # cover pic
        COVER_PIC=`echo -e "$ALL_PICS" | sort | head -1`

        # rest of pics
        PICS=`echo -e "$ALL_PICS" | sort | tail -n +2`
    fi

    if [ -z "${ALL_PICS}" ]
    then
        echo -e "${RED}no pics for $project_id${NC}" 
        continue
    fi

    echo -e "${GREEN} num of pics to copy: $(echo "${ALL_PICS}" | wc -l)${NC}"

    mkdir -p "$dest_dir/$project_id"
    
    #
    # copying cover
    #
    PIC_FILE_NAME=$(basename -- "${COVER_PIC}")
    
    PIC_EXT="${PIC_FILE_NAME##*.}"
    cp "$COVER_PIC" "$dest_dir/$project_id/${project_id}-cover.$PIC_EXT"

    if [ -z "$PICS" ]
    then
        continue
    fi
    
    #
    # copying rest of pics
    #
    I=0
    while IFS= read -r PIC; do
        I=$(($I + 1))
        PIC_FILE_NAME=$(basename -- "$PIC")
        PIC_EXT="${PIC_FILE_NAME##*.}"
        cp "$PIC" "$dest_dir/$project_id/${project_id}-${I}.$PIC_EXT"
    done <<< "$PICS"
done
