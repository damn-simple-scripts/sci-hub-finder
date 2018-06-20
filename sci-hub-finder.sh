#!/bin/bash

# dependency: curl

list_tld="https://data.iana.org/TLD/tlds-alpha-by-domain.txt"
target_file="/var/www/html/sci-hub.txt"


temp=$(tempfile)
curl -s "$list_tld" > $temp
echo "$(cat $temp | wc -l) TLD to check"

dns_res=$(tempfile)

echo "checking DNS"
cat $temp | grep -v "^#" | xargs -n 1 -i echo "sci-hub.{}" | xargs -n 1 -i bash -c "nslookup {} | | grep -A10 'Non-authoritative answer' | grep -c 'Address:' | xargs echo {} " | grep -v " 0$" | cut -d' ' -f 1 > $dns_res

echo "$(cat $dns_res | wc -l) candidates found"

echo "visiting pages"
temp_result=$(tempfile)
cat $dns_res | xargs -n 1 -i bash -c "curl -m 5 -L -s 'https://{}' | grep -c 'will always redirect to the working Sci-Hub domain\|The first pirate website in the world to open mass and public access to tens of millions research papers' | xargs -n 1 echo {}" | grep -v " 0$" | cut -d' ' -f 1 > $temp_result

echo "$(cat $temp_result | wc -l) urls found"

cat $temp_result | tee $target_file

rm $temp_result $dns_res $temp
