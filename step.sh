#!/bin/bash
# fail if any commands fails
set -e
# debug log
set -x

#Install jq
echo $OSTYPE
if [[ "$OSTYPE" == "linux-gnu" ]]; then
        sudo apt-get -y install jq
elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
fi

#GetAPP
buildslug=$(curl -H "accept: application/json" -H "Authorization: ${access_token}" -X GET https://api.bitrise.io/v0.1/apps/${app_slug}/builds?workflow=${workflow}'&'status=1'&'limit=1 | jq -r '.data[].slug ')
echo $buildslug

artifactslug=$(curl -H "accept: application/json" -H "Authorization: ${access_token}" -X GET https://api.bitrise.io/v0.1/apps/${app_slug}/builds/$buildslug/artifacts | jq --arg e "${artifact_name}" -r '.data[] | select(.title==$e) | .slug')
echo $artifactslug

lasturl=$(curl -H "accept: application/json" -H "Authorization: ${access_token}" -X GET https://api.bitrise.io/v0.1/apps/${app_slug}/builds/$buildslug/artifacts/$artifactslug | jq -r '.[] | .expiring_download_url')

(mkdir -p $BITRISE_SOURCE_DIR/${directory_name} && cd $BITRISE_SOURCE_DIR/${directory_name}
curl $lasturl > "${artifact_name}"
)
