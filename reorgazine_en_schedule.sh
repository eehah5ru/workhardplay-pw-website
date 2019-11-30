#!/bin/bash

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m' # No Color

en_rbob_sorting="en/2019/schedule/all-days/rbob-sorting"

ru_schedule="ru/2019/schedule"

for p in `find ${en_rbob_sorting} -name "*.md"`
do
    project_file_name=$(basename -- "$p")

    ru_twin=`find "${ru_schedule}" -name "${project_file_name}" | head -1`

    if [ -z "$ru_twin" ]
    then
        echo -e "${RED}no ru twin for en ${project_file_name}${NC}"
        continue
    fi

    en_header=`cat ${ru_twin} | head -3`

    en_tail=`cat ${p} | tail -n +4`

    ru_twin_dir=$(dirname "${ru_twin}")

    en_project_dir=`echo "${ru_twin_dir}" | sed -e "s/ru\/2019/en\/2019/g"`

    echo "${project_file_name} - ${ru_twin} - ${en_project_dir}"

    mkdir -p "${en_project_dir}"

    echo "${en_header}" > "${en_project_dir}/${project_file_name}"
    echo "${en_tail}" >> "${en_project_dir}/${project_file_name}"

    #cp "${p}" "${en_project_dir}"
done
