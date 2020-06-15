# WPHP website

## schedule

### requirements

install drive cli: `pip install drive-cli` 

### environment

set `WHPH_YEAR` env var

`export WHPH_YEAR="2020"`

### commands

collect all links to unprocessed applications:  
`find /Volumes/qz1_after/google_drives/work.hard.play.0/РБОБ/РБОБ\ 2019/_заявки -name "*.gdoc" -exec sh -c 'echo {}' \; | grep -v "_заявки/-" | grep -v "_заявки/+" | grep -v "_заявки/0 cancelled" > projects.in`

generate events:  
`./generate_events.sh`

translate sorted events from ru to en:  
`./translate_ru_en.sh`

delete all unsorted/orphan events:  
`rm -r ru/2019/schedule/all-days/rbob-sorting`

collect all formats from events:  
`find . -type f -iname "*.md" -exec cat {} \; | grep  "shortDescription:" | sed 's/shortDescription: "//' | sed 's/"//' | sort | uniq | sed 's/$/,/' | tr '\n' ' '  | pbcopy`


### to clarify

`./create_project_covers.sh`

`./projects_report.sh`

`./reorgazine_en_schedule.sh`

`./print_authors.sh ru`

`./print_authors.sh en`

`./check_project_covers.sh`

`pbpaste | xargs drive cat --ftype txt | stack exec generate-event-file -- ru`

`pbpaste | xargs drive cat --ftype txt | stack exec generate-event-file -- en`

`(for p in ``cat projects.in``; do cat "$p"| jq -r .url | tee /dev/fd/2| xargs drive cat --ftype txt| stack exec check-project-file; done) 2>&1 > good_projects.txt`

`./projects_report.sh 2>&1 | tee | pbcopy`

`(for p in ``cat projects.in``; do cat "$p"| jq -r .url | tee /dev/fd/2| xargs drive cat --ftype txt| stack exec check-project-file; done) 2>&1 > good_projects.txt`

` for p in ``cat projects.in``; do cat "$p"| jq -r .url | tee /dev/fd/2| xargs drive cat --ftype txt| stack exec generate-participant-file; done`

`for p in ``cat projects.in``; do cat "$p"| jq -r .url | tee /dev/fd/2| xargs drive cat --ftype txt| stack exec generate-event-file; done`

`for p in ``cat projects.in``; do cat "$p"| jq -r .url | tee /dev/fd/2| xargs drive cat --ftype txt| stack exec generate-project-id; done`

`for p in ``cat projects.in``; do cat "$p"| jq -r .url | tee /dev/fd/2| xargs drive cat --ftype txt| stack exec generate-participant-id; done`

## WHPH MC - master

### build binary
- `rake vagrant:master:deploy_bin`

### start server locally
- `rake vagrant:master:watch`
- `rake vagrant:master:rsync_auto`
