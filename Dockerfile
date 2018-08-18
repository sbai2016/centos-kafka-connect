FROM centos:7

ENV ARTIFACTORY_URL=172.22.1.150
ENV KAFKA_VERSION=1.0.0
ENV KAFKA_NAME=kafka_2.11
ENV KAFKA_BIN=${KAFKA_NAME}-${KAFKA_VERSION}.tar.gz

ENV KAFKA_CONFLUENT_VERSION=4.0.0
ENV KAFKA_CONFLUENT_NAME=confluent-oss
ENV KAFKA_CONFLUENT_BIN=${KAFKA_CONFLUENT_NAME}-${KAFKA_CONFLUENT_VERSION}.tar.gz

RUN yum -y install java-1.8.0-openjdk which openssh openssh-server openssh-clients 
RUN yum -y install net-tools.x86_64 telnet git java-1.8.0-openjdk-devel
#UTILISATEUR KAFKA
RUN groupadd -g 1000 hadoop
RUN useradd -d /opt/kafka -g hadoop kafka
RUN echo "kafka:kafka" | chpasswd


#droits kafka
RUN chown -R kafka:hadoop /opt/kafka

ENV KAFKA_PLUGINS_DIR=/usr/local/share/kafka/plugins
RUN mkdir -p ${KAFKA_PLUGINS_DIR}
RUN chown -R kafka:hadoop ${KAFKA_PLUGINS_DIR}

# ################################
# USER kafka
# ################################
USER kafka

#SSH kafka
RUN mkdir -p /opt/kafka/.ssh/
RUN ssh-keygen -t rsa -P '' -f /opt/kafka/.ssh/id_rsa
RUN cat /opt/kafka/.ssh/id_rsa.pub >> /opt/kafka/.ssh/authorized_keys
RUN chmod 0600 /opt/kafka/.ssh/authorized_keys
RUN chown -R kafka:hadoop /opt/kafka/.ssh

WORKDIR /tmp
RUN curl -L -O http://${ARTIFACTORY_URL}/artifactory/libs-release-local/fr/cnamts/p8/${KAFKA_NAME}/${KAFKA_VERSION}/${KAFKA_BIN} \
     && tar xfz ${KAFKA_BIN} -C /opt/kafka/ \
     && rm ${KAFKA_BIN}
RUN cp -rf /opt/kafka/${KAFKA_NAME}-${KAFKA_VERSION}/* /opt/kafka/

#CONF KAFKA
COPY ./kafka/.bashrc /opt/kafka
COPY ./kafka/conf/connect-distributed.properties /opt/kafka/config

# ################################
# USER root
# ################################
USER root
VOLUME /opt/kafka

RUN chown -R kafka:hadoop /opt/kafka/config


ARG MAVEN_VERSION=3.5.2
ARG USER_HOME_DIR="/opt/kafka"
ARG SHA=707b1f6e390a65bde4af4cdaf2a24d45fc19a6ded00fff02e91626e3e42ceaff
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha256sum -c - \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

#COPY mvn-entrypoint.sh /usr/local/bin/mvn-entrypoint.sh
#COPY settings-docker.xml /usr/share/maven/ref/

# ################################
# USER kafka
# ################################
USER kafka

#KAFKA CONFLUENT
WORKDIR ${KAFKA_PLUGINS_DIR}

RUN curl -L -O http://${ARTIFACTORY_URL}/artifactory/libs-release-local/fr/cnamts/p8/${KAFKA_CONFLUENT_NAME}/${KAFKA_CONFLUENT_VERSION}/${KAFKA_CONFLUENT_BIN} \
     && tar xfz ${KAFKA_CONFLUENT_BIN} \
     && rm ${KAFKA_CONFLUENT_BIN}
RUN cp -R ${KAFKA_PLUGINS_DIR}/confluent-${KAFKA_CONFLUENT_VERSION}/* ${KAFKA_PLUGINS_DIR}
RUN rm -rf ${KAFKA_PLUGINS_DIR}/confluent-${KAFKA_CONFLUENT_VERSION}



#ENTRYPOINT 
WORKDIR /opt/kafka
COPY ./kafka/scripts/entrypoint.sh ./

ENTRYPOINT ["bash", "-c", "/opt/kafka/entrypoint.sh"]
