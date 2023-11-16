#!/bin/sh
set -e

_preflight() {
  echo 'Preflight started.'
  if [ -z "$RELAY_HOST" ]; then
    echo "RELAY_HOST is not set. Please set RELAY_HOST to the hostname of the relay"
    exit 1
  fi

}

_codecov_preflight() {
  echo 'Codecov preflight started.'
  COUNTER=0
  echo 'Waiting for Codecov to be available ...'

  while [ -z "`nc -vz $CODECOV_HOST $CODECOV_PORT 2>&1 | grep open`" ]; do
    COUNTER=$(($COUNTER+1))
    if [ "$COUNTER" -gt 30 ]; then
      echo "Timeout waiting for Codecov to be available"
      echo "Check configuration, Check firewall, Check routing to internet, Ensure egress ip of this container is allowed in Codecov install"
      exit 1
    elif [ "$COUNTER" -eq 15 ]; then
        echo 'Still waiting for Codecov to be available ...'
    fi
    sleep 1
  done
  echo 'Codecov available.'
  return 0

}
_relay_preflight() {
  echo 'Relay preflight started.'
  COUNTER=0
  echo 'Waiting for Relay to be available ...'

  while [ -z "`nc -vz $RELAY_HOST $RELAY_PORT 2>&1 | grep open`" ]; do
    COUNTER=$(($COUNTER+1))
    if [ "$COUNTER" -gt 30 ]; then
      echo "Timeout waiting for Relay to be available"
      echo "Check configuration, Check firewall, Check internal routing to relay host"
      exit 1
    elif [ "$COUNTER" -eq 15 ]; then
        echo 'Still waiting for Relay to be available ...'
    fi
    sleep 1
  done
  echo 'Relay available.'
  return 0

}

_start_haproxy() {
  export DOLLAR='$'
  BASE_CONF="-f /etc/haproxy/0-haproxy.conf -f /etc/haproxy/1-defaults.conf"
  CODECOV_RELAY="-f /etc/haproxy/3-codecov-relay.conf"
  RELAY="-f /etc/haproxy/2-relay.conf"
  if [ "$CODECOV_RELAY_DISABLED" ]; then
    echo 'Codecov relay disabled'
    CODECOV_RELAY=""
  else
    envsubst < /etc/haproxy/3-codecov-relay.conf.template > /etc/haproxy/3-codecov-relay.conf
  fi
  envsubst < /etc/haproxy/2-relay.conf.template > /etc/haproxy/2-relay.conf

  if [ "$CODECOV_RELAY_CHROOT_DISABLED" ]; then
    echo 'Codecov gateway chroot disabled'
    envsubst < /etc/haproxy/0-haproxy-no-chroot.conf.template > /etc/haproxy/0-haproxy.conf
  else
    envsubst < /etc/haproxy/0-haproxy.conf.template > /etc/haproxy/0-haproxy.conf
  fi

  echo "Starting haproxy"
  haproxy -W -db $BASE_CONF $RELAY $CODECOV_RELAY
}

if [ -z "$1" ];
then
  _preflight
  _relay_preflight
  if [ -z "$CODECOV_RELAY_DISABLED" ]; then
     _codecov_preflight
  fi
  _start_haproxy
else
  exec "$@"
fi

