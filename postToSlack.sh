#!/usr/bin/env bash

function usage {
    programName=$0
    echo "description: use this program to post messages to Slack channel"
    echo "usage: $programName <-t \"sample title\"> <-b \"message body\"> <-c \"mychannel\"> <-u \"slack url\"> [-n \"username\"] [-i \"icon\"]"
    echo "	-t    the title of the message you are posting"
    echo "	-b    The message body"
    echo "	-c    The channel you are posting to"
    echo "	-u    The slack hook url to post to"
    echo "	-n    The username"
    echo "	-i    The emoji icon to use"
    exit 1
}

userName=$(hostname)
icon=sunglasses

while getopts ":t:b:c:u:n:i:h" opt; do
  case ${opt} in
    t) msgTitle="$OPTARG"
    ;;
    u) slackUrl="$OPTARG"
    ;;
    b) msgBody="$OPTARG"
    ;;
    c) channelName="$OPTARG"
    ;;
    n) userName="$OPTARG"
    ;;
    i) icon="$OPTARG"
    ;;
    h) usage
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if [[ ! "${msgTitle}" ||  ! "${slackUrl}" || ! "${msgBody}" || ! "${channelName}" ]]; then
    echo "The title, body, channel and hook URL are required"
    usage
fi



read -d '' payLoad << EOF
{
        "channel": "#${channelName}",
        "username": "${userName}",
        "icon_emoji": ":${icon}:",
        "attachments": [
            {
                "fallback": "${msgTitle}",
                "color": "good",
                "title": "${msgTitle}",
                "fields": [{
                    "title": "message",
                    "value": "${msgBody}",
                    "short": false
                }]
            }
        ]
    }
EOF


statusCode=$(curl \
        --write-out %{http_code} \
        --silent \
        --output /dev/null \
        -X POST \
        -H 'Content-type: application/json' \
        --data "${payLoad}" ${slackUrl})

echo ${statusCode}
