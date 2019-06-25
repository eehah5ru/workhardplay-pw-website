#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m' # No Color

en_rbob_sorting="en/2019/schedule/all-days/rbob-sorting"

ru_schedule="ru/2019/schedule"

for ru_project in `find ${ru_schedule} -name "*.md"`
do


    is_project=`cat ${ru_project} | grep '^time:'`
    if [ -z "${is_project}" ]
    then
        echo -e "${RED}skipping ${ru_project}${NC}"
        continue
    fi

    project_file_name=$(basename -- "$ru_project")

    en_unsorted=`find "${en_rbob_sorting}" -name "${project_file_name}" | head -1`

    if [ -z "${en_unsorted}" ]
    then
        echo -e "${RED} NO EN FILE FOR ${project_file_name}"
        continue
    fi

    ru_project_dir=$(dirname "${ru_project}")

    en_project_dir=`echo "${ru_project_dir}" | sed -e "s/ru\/2019/en\/2019/g"`

    en_dest_project="${en_project_dir}/${project_file_name}"

    mkdir -p "${en_project_dir}"

    en_header=`cat ${ru_project} | head -3`

    en_tail=`cat ${en_unsorted} | tail -n +4 | grep -v  '^projectIdSuffix:'`

    en_extra_headers=`cat ${ru_project} | grep -e 'projectIdSuffix:' -e 'hideShortDescription:'`

    # echo "${en_header}" > "${en_project_dir}/${project_file_name}"
    # echo "${en_tail}" >> "${en_project_dir}/${project_file_name}"

    echo "${en_header}" > "${en_dest_project}"
    echo "${en_extra_headers}" >> "${en_dest_project}"
    echo "${en_tail}" >> "${en_dest_project}"


    # project_file_name=$(basename -- "$p")

    # ru_twin=`find "${ru_schedule}" -name "${project_file_name}" | head -1`

    # if [ -z "$ru_twin" ]
    # then
    #     echo -e "${RED}no ru twin for en ${project_file_name}${NC}"
    #     continue
    # fi

    # en_header=`cat ${ru_twin} | head -3`

    # en_tail=`cat ${p} | tail -n +4`

    # ru_twin_dir=$(dirname "${ru_twin}")

    # en_project_dir=`echo "${ru_twin_dir}" | sed -e "s/ru\/2019/en\/2019/g"`

    # echo "${project_file_name} - ${ru_twin} - ${en_project_dir}"

    # mkdir -p "${en_project_dir}"

    # echo "${en_header}" > "${en_project_dir}/${project_file_name}"
    # echo "${en_tail}" >> "${en_project_dir}/${project_file_name}"

    #cp "${p}" "${en_project_dir}"
done
