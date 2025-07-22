#!/bin/sh
# ----------------------------------------------------------------------------
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# Maven Wrapper script for Maven 3.9.3
# ----------------------------------------------------------------------------

set -euf
[ "${MVNW_VERBOSE-}" != "true" ] || set -x

# OS specific support.
native_path() { printf %s\\n "$1"; }
case "$(uname)" in
CYGWIN* | MINGW*)
  [ -z "${JAVA_HOME-}" ] || JAVA_HOME="$(cygpath --unix "$JAVA_HOME")"
  native_path() { cygpath --path --windows "$1"; }
  ;;
esac

# set JAVACMD and JAVACCMD
set_java_home() {
  # For Cygwin and MinGW, ensure paths are in Unix format before anything is touched
  if [ -n "${JAVA_HOME-}" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
      # IBM's JDK on AIX uses strange locations for the executables
      JAVACMD="$JAVA_HOME/jre/sh/java"
      JAVACCMD="$JAVA_HOME/jre/sh/javac"
    else
      JAVACMD="$JAVA_HOME/bin/java"
      JAVACCMD="$JAVA_HOME/bin/javac"
    fi
    if [ ! -x "$JAVACMD" ] ; then
      printf "Error: JAVA_HOME is set to an invalid directory: %s\\n\\n" "$JAVA_HOME" >&2
      printf "Please set the JAVA_HOME variable in your environment to match the\\n" >&2
      printf "location of your Java installation.\\n" >&2
      exit 1
    fi
  else
    JAVACMD="java"
    JAVACCMD="javac"
    if ! command -v java >/dev/null 2>&1; then
      printf "Error: JAVA_HOME is not set and no 'java' command could be found in your PATH.\\n\\n" >&2
      printf "Please set the JAVA_HOME variable in your environment to match the\\n" >&2
      printf "location of your Java installation.\\n" >&2
      exit 1
    fi
  fi
}

# hash string like Java String::hashCode
hash_string() {
  str="${1:-}" h=0
  while [ -n "$str" ]; do
    char="${str%"${str#?}"}"
    h=$(( ( 31 * h + $(LC_CTYPE=C printf %d "'$char") ) % 4294967296 ))
    str="${str#?}"
  done
  printf %s\\n "$h"
}

verbose() { :; }
[ "${MVNW_VERBOSE-}" != "true" ] || verbose() { printf %s\\n "${1-}"; }

die() {
  printf %s\\n "$1" >&2
  exit 1
}

# parse distributionUrl and optional distributionSha256Sum, requires .mvn/wrapper/maven-wrapper.properties
while IFS="=" read -r key value; do
  case "${key-}" in
  distributionUrl) distributionUrl="${value-}" ;;
  distributionSha256Sum) distributionSha256Sum="${value-}" ;;
  esac
done < "${0%/*}/.mvn/wrapper/maven-wrapper.properties" || die "Cannot read ${0%/*}/.mvn/wrapper/maven-wrapper.properties"

set_java_home

distributionUrlName="${distributionUrl##*/}"
distributionUrlNameMain="${distributionUrlName%.*}"
distributionUrlNameMain="${distributionUrlNameMain%-bin}"
MAVEN_HOME="${MAVEN_USER_HOME:-${HOME}/.m2}/wrapper/dists/${distributionUrlNameMain}/$(hash_string "$distributionUrl")"

exec_maven() {
  unset MAVEN_PROJECTBASEDIR MAVEN_OPTS MAVEN_SKIP_RC
  exec "$MAVEN_HOME/bin/mvn" "$@"
}

exec_maven_if_exists() {
  [ -x "$MAVEN_HOME/bin/mvn" ] && exec_maven "$@"
}

download_and_install_maven() {
  distributionUrlPath="${distributionUrl#*://*/}"
  distributionUrlHost="${distributionUrl%/"$distributionUrlPath"}"
  distributionUrlFile="${distributionUrl##*/}"

  verbose "Downloading Maven from $distributionUrl"
  
  # Download to temp file
  tmp="$(mktemp)" && curl -fsSL "$distributionUrl" -o "$tmp" || die "Cannot download Maven from $distributionUrl"
  
  # Verify checksum if provided
  if [ -n "${distributionSha256Sum-}" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      printf "%s  %s\\n" "$distributionSha256Sum" "$tmp" | sha256sum -c - >/dev/null 2>&1 || die "Checksum verification failed"
    elif command -v shasum >/dev/null 2>&1; then
      printf "%s  %s\\n" "$distributionSha256Sum" "$tmp" | shasum -a 256 -c - >/dev/null 2>&1 || die "Checksum verification failed"
    else
      verbose "Warning: Could not verify Maven checksum"
    fi
  fi
  
  # Create directories and extract
  mkdir -p "${MAVEN_HOME%/*}" || die "Cannot create Maven home directory"
  case "$distributionUrlFile" in
    *.tar.gz) tar -xzf "$tmp" -C "${MAVEN_HOME%/*}" --strip-components=1 ;;
    *.zip) unzip -q "$tmp" -d "${MAVEN_HOME%/*}" && mv "${MAVEN_HOME%/*}"/*/* "$MAVEN_HOME" ;;
    *) die "Unsupported Maven distribution file format: $distributionUrlFile"
  esac
  
  rm -f "$tmp"
  chmod +x "$MAVEN_HOME/bin/mvn" || die "Cannot make Maven executable"
  verbose "Maven installed to $MAVEN_HOME"
}

# Check if Maven is already installed, if not download and install
exec_maven_if_exists "$@" || {
  download_and_install_maven
  exec_maven "$@"
}