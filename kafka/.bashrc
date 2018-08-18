## JAVA env variables
export JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar
#KAFKA
export KAFKA_HOME=/opt/kafka
export PATH=$PATH:$KAFKA_HOME/bin
export CONFLUENT_HOME=/usr/local/share/kafka/plugins