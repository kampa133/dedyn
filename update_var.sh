#!/usr/local/bin/bash
#this is used to update A *and* AAAA records
# set to 1 to debug
DEBUG="0"
# read vars conf file is:
# DOMAIN=xxx.dedyn.io
# TOKEN=123456789123456789
DIR=~/git/dedyn
CONF=$DIR/update.conf
# set vars
source $CONF
HOSTNAME=`hostname`
FQDN="$HOSTNAME"."$DOMAIN"
### define functions ###
function_get_IPv6 () {
    case $(uname) in
        FreeBSD)
            IPv6=`ifconfig | grep 2003 | awk '{print $2}'`
            PREFIX=`ndp -p | grep 2003 | awk '{print $1}' | sed 's/::\/64//g'`
            ;;
        Linux)
            IPv6=`ip -6 a | grep inet6 | awk '{print $2}'| grep '^2' | sed 's/\/64//g'`
            PREFIX=`ip -6 r s | grep '^2' | head -1 | awk '{print $1}' | sed 's/::\/64//g'`
            ;;
        Darwin)
            echo "Der feine Herr :-D"
            exit 1
            ;;
        *)
        echo "OS not supported"
        exit 1
    esac
}

function_update_A () {
    IPv4=`curl https://checkipv4.dedyn.io/`
    curl -X PATCH https://desec.io/api/v1/domains/$DOMAIN/rrsets/$HOSTNAME/A/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "A", "ttl": 3600, "records": ["'$IPv4'"]}'
}

function_update_AAAA () {
        curl -X PATCH https://desec.io/api/v1/domains/$DOMAIN/rrsets/$HOSTNAME/AAAA/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "AAAA", "ttl": 3600, "records": ["'$IPv6'"]}'

}

function_create_AAAA () {
    curl -X POST https://desec.io/api/v1/domains/$DOMAIN/rrsets/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "AAAA", "ttl": 3600, "records": ["'$IPv6'"]}'
}

function_create_A () {
    IPv4=`curl https://checkipv4.dedyn.io/`
    curl -X POST https://desec.io/api/v1/domains/$DOMAIN/rrsets/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "A", "ttl": 3600, "records": ["'$IPv4'"]}'
}

function_check_AAAA () {
    host "$FQDN" | grep IPv6
    if [[ $? -eq 0 ]]; then
        AAAA=`host $FQDN | grep IPv6 | awk '{print $5}'`
        if [[ $AAAA == *"$PREFIX"* ]]; then
            echo "OK6"
        else
            echo "update6"
        fi
    else
        echo "create6"
    fi
}
function_check_A () {
    currentA=`dig $FQDN +short`
    if [ -z "$currentA" ];then
        echo "create4"
        function_create_A
    else
    IPv4=`curl https://checkipv4.dedyn.io/`
    if [[ $IPv4 == $currentA ]];then
            echo "OK4"
        else
            echo "update4"
            A=$IPv4
        fi
    fi
    }

### define functions ###
if [ -n "$1" ]; then
    if [ $1 = 4 ];then
        echo "IPv4 only"
        function_check_A
        exit 1
    fi
    if [ $1 = 6 ];then
        echo "IPv6 only"
        function_get_IPv6
        function_check_AAAA 
        exit 1
    fi
    if [ $1 = d ];then
        echo "dualstack"
        function_get_IPv6
        function_check_AAAA
        function_check_A
        exit 1
    fi
    if [ $1 = X ];then
        echo "delete"
        curl -X PATCH https://desec.io/api/v1/domains/$DOMAIN/rrsets/$HOSTNAME/AAAA/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "AAAA", "ttl": 3600, "records": []}'
        curl -X PATCH https://desec.io/api/v1/domains/$DOMAIN/rrsets/$HOSTNAME/A/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "A", "ttl": 3600, "records": []}'
    else
        echo "Variables are 4 6 (d)ualstack oder X delete"
        exit 0
    fi
else
    echo "First parameter not supplied."
    exit 1
fi
}

# if [[ $DEBUG == "1" ]]; then
#     #detect public IPv4
#     IPv4=`curl https://checkipv4.dedyn.io/`
#     echo "DEBUG"
#     echo "CONF="$CONF
#     echo "DOMAIN="$DOMAIN
#     echo "TOKEN="$TOKEN
#     echo "HOSTNAME="$HOSTNAME
#     echo "IPv6="$IPv6
#     echo "IPv4="$IPv4
#     echo "FQDN="$FQDN
# else

### delete records
# curl -X PATCH https://desec.io/api/v1/domains/:name/rrsets/ \
#     --header "Authorization: Token {token}" \
#     --header "Content-Type: application/json" --data @- <<EOF
#     [
#       {"subname": "www", "type": "A", "ttl": 3600, "records": ["1.2.3.4"]},
#       {"subname": "www", "type": "AAAA", "records": []}
#     ]
# EOF