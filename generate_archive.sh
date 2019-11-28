#!/bin/bash

IFS=$'\n'

LANG=$1

PROJECTS_PATH="${LANG}/2019/projects"

mkdir -p "${PROJECTS_PATH}"

projects=`find ${LANG}/2019/schedule -type f`

for event_file in ${projects}
do
    project_file_name=$(basename -- "$event_file")

    project_file="${PROJECTS_PATH}/${project_file_name}"



    headers=`cat ${event_file} | grep -e 'title:' -e 'shortDescription:' -e 'participantId:' | ruby -e "STDOUT.print(STDIN.read.gsub(/title:/, 'projectTitle:'))"`

    body=`cat ${event_file} | ruby -e "STDOUT.print(STDIN.read.gsub(/---.+---\n/m, ''))"`

    echo "${project_file_name}"

    touch "${project_file}"    
    echo "---" >> "${project_file}"
    echo "${headers}" >> ${project_file}
    echo "---" >> ${project_file}
    echo "${body}" >> ${project_file}
done
