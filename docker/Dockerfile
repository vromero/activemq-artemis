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

# ActiveMQ Artemis

FROM java:8
MAINTAINER Victor Romero <victor.romero@gmail.com>

WORKDIR /src
ADD . /src

# add user and group for artemis
RUN groupadd -r artemis && useradd -r -g artemis artemis

RUN apt-get -qq -o=Dpkg::Use-Pty=0 update && apt-get -qq -o=Dpkg::Use-Pty=0 upgrade -y && \
  apt-get -qq -o=Dpkg::Use-Pty=0 install -y --no-install-recommends libaio1 xmlstarlet && \
  rm -rf /var/lib/apt/lists/*

# grab gosu for easy step-down from root
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN apt-get -qq -o=Dpkg::Use-Pty=0 update && apt-get -qq install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -q -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
	&& wget -q -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
	&& gpg --verify /usr/local/bin/gosu.asc \
	&& rm /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu

# Compile && Install
RUN cd /src && \
  ./mvnw clean install -DskipTests && \
  cd /opt && tar xvfz /src/artemis-distribution/target/apache-artemis-*-bin.tar.gz && \
  ln -s /opt/apache-artemis-* /opt/apache-artemis

# Create broker instance
RUN cd /var/lib && \
  /opt/apache-artemis/bin/artemis create artemis \
    --home /opt/apache-artemis \
    --user artemis \
    --password simetraehcapa \
    --role amq \
    --require-login \
    --cluster-user artemisCluster \
    --cluster-password simetraehcaparetsulc

# Ports are only exposed with an explicit argument, there is no need to binding
# the web console to localhost
RUN cd /var/lib/artemis/etc && \
  xmlstarlet ed -L -N amq="http://activemq.org/schema" \
    -u "/amq:broker/amq:web/@bind" \
    -v "http://0.0.0.0:8161" bootstrap.xml

RUN chown -R artemis.artemis /var/lib/artemis

# Web Server
EXPOSE 8161

# Port for CORE,MQTT,AMQP,HORNETQ,STOMP,OPENWIRE
EXPOSE 61616

# Port for HORNETQ,STOMP
EXPOSE 5445

# Port for AMQP
EXPOSE 5672

# Port for MQTT
EXPOSE 1883

#Port for STOMP
EXPOSE 61613

# Expose some outstanding folders
VOLUME ["/var/lib/artemis/data"]
VOLUME ["/var/lib/artemis/tmp"]
VOLUME ["/var/lib/artemis/etc"]

WORKDIR /var/lib/artemis/bin

COPY docker/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["artemis-server"]
