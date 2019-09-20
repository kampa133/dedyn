#!/usr/local/bin/bash
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
# detect OS
case $(uname) in
    FreeBSD)
        IPv6=`ifconfig | grep 2003 | awk '{print $2}'`
        PREFIX=`ndp -p | grep 2003 | awk '{print $1}' | sed 's/::\/64//g'`

        ;;
    Linux)
        IPv6=`ip -6 a | grep 2003 | awk '{print $2}'| sed 's/\/64//g'`
        PREFIX=`ip -6 r s | grep 2003 | head -1 | awk '{print $1}' | sed 's/::\/64//g'`
        ;;
    Darwin)
        echo "Der feine Herr :-D"
        exit 1
        ;;
    *)
    echo "OS not supported"
    exit 1
esac

if [[ $DEBUG == "1" ]]; then
    echo "DEBUG"
    echo "CONF="$CONF
    echo "DOMAIN="$DOMAIN
    echo "TOKEN="$TOKEN
    echo "HOSTNAME="$HOSTNAME
    echo "IPv6="$IPv6
    echo "FQDN="$FQDN
else
    # if domain exists:
    # need to flush DNS cache before
    host "$FQDN"
    if [[ $? -eq 0 ]]; then
        AAAA=`host $FQDN | awk '{print $5}'`
        if [[ $AAAA == *"$PREFIX"* ]]; then
            exit 1
        else
            # update subdomain
            curl -X PATCH https://desec.io/api/v1/domains/$DOMAIN/rrsets/$HOSTNAME/AAAA/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "AAAA", "ttl": 3600, "records": ["'$IPv6'"]}'
        fi
    else
        # create/register subdomain
        curl -X POST https://desec.io/api/v1/domains/$DOMAIN/rrsets/ --header "Authorization: Token $TOKEN" --header "Content-Type: application/json" --data @- <<< '{"subname": "'$HOSTNAME'", "type": "AAAA", "ttl": 3600, "records": ["'$IPv6'"]}'
    fi
fi

