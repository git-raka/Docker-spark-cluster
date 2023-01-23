FROM openjdk:11 as builder

#update
RUN apt-get update -y

#Python & other dependencies
RUN apt-get install -y curl vim wget software-properties-common ssh net-tools python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas
RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

#Define spark home
ENV SPARK_HOME=/opt/spark 

#Extract and download spark
RUN wget --no-verbose  https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz && \
    mkdir -p /opt/spark && \
    mkdir /opt/spark/logs && \
    mkdir /opt/spark/jars && \
    echo "" /opt/spark/logs/spark-master.out && \ 
    echo "" /opt/spark/logs/spark-master.out && \
    tar -xzf spark-3.3.1-bin-hadoop3.tgz -C /opt/spark --strip-components=1 && \
    rm -rf spark-3.3.1-bin-hadoop3.tgz

#Define builder 
FROM builder as apache-spark

#used directory
WORKDIR /opt/spark

#Jar download
RUN  wget --no-verbose https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.0.0/hadoop-aws-3.0.0.jar -P /opt/spark/jars && \
     wget --no-verbose https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.389/aws-java-sdk-bundle-1.12.389.jar -P /opt/spark/jars && \
     wget --no-verbose https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-common/3.0.0/hadoop-common-3.0.0.jar -P /opt/spark/jars && \
     wget --no-verbose https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-client/3.0.0/hadoop-client-3.0.0.jar -P /opt/spark/jars

#Spark configuration
ENV SPARK_MASTER_PORT=7077 \
SPARK_MASTER_WEBUI_PORT=8080 \
SPARK_LOG_DIR=/opt/spark/logs \
SPARK_MASTER_LOG=/opt/spark/logs/spark-master.out \
SPARK_WORKER_LOG=/opt/spark/logs/spark-worker.out \
SPARK_WORKER_WEBUI_PORT=8080 \
SPARK_WORKER_PORT=7000 \
SPARK_MASTER="spark://spark-master:7077" \
SPARK_WORKLOAD="master"

#Open port
EXPOSE 8080 7077 7000

COPY start-spark.sh /

# start-spark.sh
CMD ["/bin/bash", "/start-spark.sh"]
