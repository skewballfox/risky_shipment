# make the necessary directories
[ ! -d ./data/ ] && mkdir ./data/
[ ! -d ./data/latest ] && mkdir ./data/latest

untar_flag=false
curl_flag=false

#first check to see if a copy of the data dump is local
if [ ! -f ./data/db-dump.tar.gz ]; then
    curl_flag=true
    untar_flag=true
else
    #if it exist check if it's over 24 hours old
    # Thanks to: https://www.unix.com/shell-programming-and-scripting/156100-test-if-file-has-last-modified-date-within-last-24-hours.html
    if [ $(find /path -mtime -1 -type f -name "./data/db-dump.tar.gz" 2>/dev/null) ]; then
        curl_flag=true
        untar_flag=true
    else
        #lastly if it exist and is recent, check if it's been unpacked
        #probably overkill but just to be on the safe side
        if [ -z "$(ls -A ./data/latest)" ]; then
            untar_flag=true
        fi
    fi
fi

#pull the latest data dump only if necessary
if [ "$curl_flag" = true ]; then
    curl -L -o data/db-dump.tar.gz https://static.crates.io/db-dump.tar.gz
fi

#untar it only if necessary
if [ "$untar_flag" = true ]; then
    tar -xvf data/db-dump.tar.gz -C ./data/latest --strip-components=1
fi

#for second approach, adding data as volume and
# importing data at instantiation
#import_cmd=$(cat ./data/latest/import.sql)

# check whether to use docker or podman
container_cmd=$(type -p podman || type -p docker)

$container_cmd build -t risky_shipment

$container_cmd run -it --rm --network="host" --name risky_shipment risky_shipment
# $container_cmd run -it \
#     --network="host" \
#     --volume ./data/latest/data:/data \
#     --name risky_shipment risky_shipment \
#     psql -d crates_db =c $import_cmd
