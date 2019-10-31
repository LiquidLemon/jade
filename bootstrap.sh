#!/bin/bash
set -eu

if [ "$#" -ne 1 ]; then
  echo "usage: $0 INDEX"
  exit 1
fi

INDEX=$1
WORKDIR="${PWD}/sa_lab2_${INDEX}"

mkdir "${WORKDIR}"
cd "${WORKDIR}"

FILE=$(mktemp)
wget "http://infinity.eti.pg.gda.pl/tmp/jade.zip" -O "${FILE}"
unzip "${FILE}" -d "${WORKDIR}"
rm "${FILE}"

JAVA_HOME=$(update-java-alternatives --list | grep 1.8.0 | awk '{print $3}')

sed "s/, anon,/,/" "${JAVA_HOME}/jre/lib/security/java.security" > "${WORKDIR}/jade/java.sec"
