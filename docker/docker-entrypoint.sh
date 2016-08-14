#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements. See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership. The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License. You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied. See the License for the
# specific language governing permissions and limitations
# under the License.
#

set -e

# Log to tty to enable docker logs container-name
sed -i "s/logger.handlers=.*/logger.handlers=CONSOLE/g" ../etc/logging.properties

# Update users and roles with if username and password is passed as argument
if [[ "$ARTEMIS_USERNAME" && "$ARTEMIS_PASSWORD" ]]; then
  sed -i "s/artemis=amq/$ARTEMIS_USERNAME=amq/g" ../etc/artemis-roles.properties
  sed -i "s/artemis=simetraehcapa/$ARTEMIS_USERNAME=$ARTEMIS_PASSWORD/g" ../etc/artemis-users.properties
fi

# Update min memory if the argument is passed
if [[ "$ARTEMIS_MIN_MEMORY" ]]; then
  sed -i "s/-Xms512M/-Xms$ARTEMIS_MIN_MEMORY/g" ../etc/artemis.profile
fi

# Update max memory if the argument is passed
if [[ "$ARTEMIS_MAX_MEMORY" ]]; then
  sed -i "s/-Xmx1024M/-Xmx$ARTEMIS_MAX_MEMORY/g" ../etc/artemis.profile
fi

if [ "$1" = 'artemis-server' ]; then
	set -- gosu artemis "./artemis" "run"
fi

exec "$@"
