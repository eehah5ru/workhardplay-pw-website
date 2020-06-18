#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

ru_schedule="ru/$WHPH_YEAR/schedule"

for ru_structure_file in `find ${ru_schedule} -name "*.md"`
do


    is_project=`cat ${ru_structure_file} | grep '^time:'`
    if [ ! -z "${is_project}" ]
    then
        echo -e "${RED}skipping ${ru_structure_file}${NC}"
        continue
    fi

    structure_file_name=$(basename -- "$ru_structure_file")


    ru_dir=$(dirname "${ru_structure_file}")

    en_dir=`echo "${ru_dir}" | sed -e "s/ru\/$WHPH_YEAR/en\/$WHPH_YEAR/g"`

    en_dest_file="${en_dir}/${structure_file_name}"

    mkdir -p "${en_dir}"

    echo "$ru_structure_file -> $en_dest_file"
    cp $ru_structure_file $en_dest_file
done
