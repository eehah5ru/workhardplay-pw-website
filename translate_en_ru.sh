#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m' # No Color

if [ -z "$WHPH_YEAR" ]
then
    echo "ERROR: please set WHPH_YEAR"
    exit 1
fi

FROM="en"

TO="ru"

to_rbob_sorting="$TO/$WHPH_YEAR/schedule/all-days/rbob-sorting"

from_schedule="$FROM/$WHPH_YEAR/schedule"

for from_project in `find ${from_schedule} -name "*.md"`
do


    is_project=`cat ${from_project} | grep '^time:'`
    if [ -z "${is_project}" ]
    then
        echo -e "${RED}skipping ${from_project}${NC}"
        continue
    fi

    project_file_name=$(basename -- "$from_project")

    to_unsorted=`find "${to_rbob_sorting}" -name "${project_file_name}" | head -1`

    if [ -z "${to_unsorted}" ]
    then
        echo -e "${RED} NO $TO FILE FOR ${project_file_name}"
        continue
    fi

    from_project_dir=$(dirname "${from_project}")

    to_project_dir=`echo "${from_project_dir}" | sed -e "s/$FROM\/$WHPH_YEAR/$TO\/$WHPH_YEAR/g"`

    to_dest_project="${to_project_dir}/${project_file_name}"

    mkdir -p "${to_project_dir}"

    to_header=`cat ${from_project} | head -3`

    to_tail=`cat ${to_unsorted} | tail -n +4 | grep -v  '^projectIdSuffix:'`

    to_extra_headers=`cat ${from_project} | grep -e 'projectIdSuffix:' -e 'hideShortDescription:'`

    # echo "${to_header}" > "${to_project_dir}/${project_file_name}"
    # echo "${to_tail}" >> "${to_project_dir}/${project_file_name}"

    echo "${to_header}" > "${to_dest_project}"
    echo "${to_extra_headers}" >> "${to_dest_project}"
    echo "${to_tail}" >> "${to_dest_project}"


    # project_file_name=$(basename -- "$p")

    # from_twin=`find "${from_schedule}" -name "${project_file_name}" | head -1`

    # if [ -z "$from_twin" ]
    # then
    #     echo -e "${RED}no ru twin for en ${project_file_name}${NC}"
    #     continue
    # fi

    # to_header=`cat ${from_twin} | head -3`

    # to_tail=`cat ${p} | tail -n +4`

    # from_twin_dir=$(dirname "${from_twin}")

    # to_project_dir=`echo "${from_twin_dir}" | sed -e "s/ru\/$WHPH_YEAR/en\/$WHPH_YEAR/g"`

    # echo "${project_file_name} - ${from_twin} - ${to_project_dir}"

    # mkdir -p "${to_project_dir}"

    # echo "${to_header}" > "${to_project_dir}/${project_file_name}"
    # echo "${to_tail}" >> "${to_project_dir}/${project_file_name}"

    #cp "${p}" "${to_project_dir}"
done
