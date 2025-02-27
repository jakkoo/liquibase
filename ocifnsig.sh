#!/bin/bash

########################## Fill these in with your values ##########################
#OCID of the tenancy calls are being made in to
tenancy_ocid="ocid1.tenancy.oc1..aaaaaaaafhjimjaooi6dylrxc5y7pgobfs42c2puo3v3ick6ftpa5zdtko5a"

# OCID of the user making the rest call
user_ocid="ocid1.user.oc1..aaaaaaaan5qmkn7ldgfivx7wvco7ur7zavzfluidnarakw7s2ekqtytc33mq"

# path to the private PEM format key for this user
privateKeyPath="/c/users/vsampoor/ssh_keys/oci_api_key.pem"

# fingerprint of the private key for this user
fingerprint="5d:2d:bc:ae:c0:c5:d4:63:82:bd:d4:a4:52:dd:c3:f3"

# The REST api you want to call, with any required paramters.
rest_api="/20181201/functions/ocid1.fnfunc.oc1.iad.aaaaaaaahrlzn4c4qjz2ytdqo5k5ofjfwtohj3jw64oqz542lb4q36hy2xxa/actions/invoke
"

# The host you want to make the call against
host="wdsl4ytscxa.us-ashburn-1.functions.oci.oraclecloud.com"

# the json file containing the data you want to POST to the rest endpoint
body="/c/users/vsampoor/documents/ocifnrequst.json"
####################################################################################
echo "body****$body"

# extra headers required for a POST/PUT request
body_arg=(--data-binary @${body})
content_sha256="$(openssl dgst -binary -sha256 < $body | openssl enc -e -base64)";
content_sha256_header="x-content-sha256: $content_sha256"
content_length="$(wc -c < $body | xargs)";
content_length_header="content-length: $content_length"
headers="(request-target) date host"
# add on the extra fields required for a POST/PUT
#headers=$headers" x-content-sha256 content-type content-length"
content_type_header="content-type: application/json";

date=`date -u "+%a, %d %h %Y %H:%M:%S GMT"`
date_header="date: $date"
host_header="host: $host"
request_target="(request-target): post $rest_api"

# note the order of items. The order in the signing_string matches the order in the headers, including the extra POST fields
signing_string="$request_target\n$date_header\n$host_header"
# add on the extra fields required for a POST/PUT
#signing_string="$signing_string\n$content_sha256_header\n$content_type_header\n$content_length_header"




echo "====================================================================================================="
printf '%b' "signing string is $signing_string \n"
signature=`printf '%b' "$signing_string" | openssl dgst -sha256 -sign $privateKeyPath | openssl enc -e -base64 | tr -d '\n'`
printf '%b' "Signed Request is  \n$signature\n"

echo "====================================================================================================="
set -x
curl -v -X POST --data-binary "@$body" -sS https://$host$rest_api -H "date: $date" -H "x-content-sha256: $content_sha256" -H "content-type: application/json" -H "content-length: $content_length" -H "Authorization: Signature version=\"1\",keyId=\"$tenancy_ocid/$user_ocid/$fingerprint\",algorithm=\"rsa-sha256\",headers=\"$headers\",signature=\"$signature\"" 
