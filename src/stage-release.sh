#!/bin/bash
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -e -x

if [ $# -eq 0 ]; then
    echo "Required argument with destination directory"
    exit 1
fi

DEST_PATH=$1

pushd $(dirname "$0")/..
PULSAR_PATH=$(git rev-parse --show-toplevel)
VERSION=`cat pom.xml | xmllint --format - | sed "s/xmlns=\".*\"//g" | xmllint --stream --pattern /project/version --debug - |  grep -A 2 "matches pattern" |  grep text |  sed "s/.* [0-9] //g"`
popd

cp $PULSAR_PATH/all/target/apache-pulsar-$VERSION-src.tar.gz $DEST_PATH
cp $PULSAR_PATH/all/target/apache-pulsar-$VERSION-bin.tar.gz $DEST_PATH

mkdir $DEST_PATH/RPMS
cp -r $PULSAR_PATH/pulsar-client-cpp/pkg/rpm/RPMS/x86_64/* $DEST_PATH/RPMS

mkdir $DEST_PATH/DEB
cp -r $PULSAR_PATH/pulsar-client-cpp/pkg/deb/BUILD/DEB/* $DEST_PATH/DEB

# Sign all files
cd $DEST_PATH
find . -type f | xargs $PULSAR_PATH/src/sign-release.sh
