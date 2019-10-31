#!/bin/bash
set -eu

REPLICATION=jade.core.replication.MainReplicationService
NOTIFICATION=jade.core.replication.AddressNotificationService
EVENT=jade.core.event.NotificationService

KEYSTORE_PASS="changeme"
MAIN_PORT=5656
HOST=localhost
LOCAL_HOST=localhost
PLATFORM_NAME=""
CONTAINER_NAME=""

JAVA_HOME=$(update-java-alternatives --list | grep 1.8.0 | awk '{print $3}')

SECURITY_FLAGS="
-Djava.security.properties=$PWD/java.sec \
-Djavax.net.ssl.keyStore=keystore \
-Djavax.net.ssl.keyStorePassword=$KEYSTORE_PASS \
-Djavax.net.ssl.trustStore=keystore \
"

JADE="$JAVA_HOME/bin/java $SECURITY_FLAGS -cp $PWD/lib/jade.jar jade.Boot"

KEYTOOL_FLAGS="
-keystore keystore
-storepass $KEYSTORE_PASS
-keypass $KEYSTORE_PASS
-dname CN=Unknown,OU=Unknown,O=Unknown,L=Unknown,ST=Unknown,C=Unknown
"

case "$1" in
  main)
    TYPE=""
    SERVICES="-services $EVENT;$REPLICATION;$NOTIFICATION"
    HOST=$2
    LOCAL_HOST=$2
    PORT=$3
    LOCAL_PORT=$3
    shift 3
    ;;
  replica)
    TYPE="-backupmain"
    SERVICES="-services $EVENT;$REPLICATION;$NOTIFICATION"
    HOST=$2
    PORT=$3
    LOCAL_PORT=0
    shift 3
    ;;
  federated)
    TYPE="-container"
    SERVICES="-services $EVENT;$NOTIFICATION"
    HOST=$2
    PORT=$3
    LOCAL_PORT=0
    shift 3
    ;;
  key)
    keytool -genkeypair $KEYTOOL_FLAGS -alias 01
    exit 0
    ;;
  *)
    echo Unknown command $1
    exit 1
esac

while (( "$#" )); do
  case "$1" in
    -N|--platform-name)
      PLATFORM_NAME="-name $2"
      shift 2
      ;;
    -n|--name)
      CONTAINER_NAME="-container-name $2"
      shift 2
      ;;
    -g|--gui)
      TYPE="$TYPE -gui"
      shift
      ;;
    -p|--local-port)
      LOCAL_PORT=$2
      shift 2
      ;;
    *)
      echo Unknown flag $1
      exit 1
      ;;
  esac
done

$JADE \
  -host $HOST \
  -port $PORT \
  -local-host $LOCAL_HOST \
  -local-port $LOCAL_PORT \
  -nomtp \
  -icps jade.imtp.leap.JICP.JICPSPeer \
  $PLATFORM_NAME \
  $CONTAINER_NAME \
  $TYPE \
  $SERVICES
