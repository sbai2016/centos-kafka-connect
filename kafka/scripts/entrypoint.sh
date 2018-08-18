#!/bin/bash
/usr/sbin/sshd


#bash -c "bin/connect-distributed.sh config/connect-distributed.properties"

#bash -c "bin/kafka-topics.sh --create --zookeeper zookeeper.example.org:2181 --replication-factor 1 --partitions 1 --topic topic1"
#bash -c "bin/kafka-topics.sh --list --zookeeper zookeeper.example.org:2181"

tail -f /dev/null