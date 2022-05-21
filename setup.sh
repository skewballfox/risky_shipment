# make the necessary directories
[ ! -d ./data/ ] && mkdir ./data/
[ ! -d ./data/latest ] && mkdir ./data/latest

cd ./data

untar_flag=false
curl_flag=false

#first check to see if a copy of the data dump is local
if [ ! -f da-dump.tar.gz ]; then
    curl -L -o db-dump.tar.gz https://static.crates.io/db-dump.tar.gz
    curl_flag=true
    untar_flag=true
else
    #if it exist check if it's over 24 hours old
    MTIME=$(stat -c %Y db-dump.tar.gz)
    MTIME=$(((24 * 60 * 60) + "$MTIME"))
    LTIME=$(date +%s)
    if [ "$MTIME" ] >"$LTIME"; then
        curl_flag=true
        untar_flag=true
    else
        #lastly if it exist and is recent, check if it's been unpacked
        #probably overkill but just to be on the safe side
        if [ -z "$(ls -A .data/latest)"]; then
            untar_flag=true
        fi
    fi
fi

#pull the latest data dump only if necessary
if [ "$curl_flag" = true ]; then
    curl -L -o db-dump.tar.gz https://static.crates.io/db-dump.tar.gz
fi

#untar it only if necessary
if [ "$untar_flag" = true ]; then
    tar -xvf db-dump.tar.gz -C latest --strip-components=1
fi

#switch back to main directory
cd ..

# check whether to use docker or podman
container_cmd=$(type -p podman || type -p docker)

$container_cmd build -t risky_shipment

$container_cmd run -it --rm --network="host" --name risky_shipment risky_shipment
