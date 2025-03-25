# Usa uma versão específica do Ubuntu para evitar problemas de compatibilidade
FROM ubuntu:22.04

# Define o diretório de trabalho
WORKDIR /app

# 1. Instalação de dependências básicas
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openjdk-11-jdk \
    python3 python3-pip python3-dev \
    wget curl unzip tar \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Configuração do Python como padrão
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
    && update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

# 3. Variáveis de ambiente para Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# 4. Configurações de versão
ENV SPARK_VERSION=3.4.4
ENV HADOOP_VERSION=3.3.6
ENV ZEPPELIN_VERSION=0.12.0
ENV DELTA_VERSION=2.4.0

# 5. Instalação do Spark
RUN wget -q "https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
    && tar -xzf "spark-${SPARK_VERSION}-bin-hadoop3.tgz" -C /opt \
    && rm "spark-${SPARK_VERSION}-bin-hadoop3.tgz" \
    && ln -s "/opt/spark-${SPARK_VERSION}-bin-hadoop3" /opt/spark

ENV SPARK_HOME="/opt/spark"
ENV PATH="$SPARK_HOME/bin:$PATH"

# 6. Copia os JARs da pasta local para o container
COPY jars/*.jar $SPARK_HOME/jars/

# 7. Copia o arquivo requirements.txt e instala as libs Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 8. Instalação do Hadoop
RUN wget -q "https://dlcdn.apache.org/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && tar -xzf "hadoop-${HADOOP_VERSION}.tar.gz" -C /opt \
    && rm "hadoop-${HADOOP_VERSION}.tar.gz" \
    && ln -s "/opt/hadoop-${HADOOP_VERSION}" /opt/hadoop

ENV HADOOP_HOME="/opt/hadoop"
ENV HADOOP_CONF_DIR="$HADOOP_HOME/etc/hadoop"
ENV PATH="$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH"

# 9. Instalação do Zeppelin
RUN wget -q "https://dlcdn.apache.org/zeppelin/zeppelin-${ZEPPELIN_VERSION}/zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz" \
    && tar -xzf "zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz" -C /opt \
    && rm "zeppelin-${ZEPPELIN_VERSION}-bin-all.tgz" \
    && ln -s "/opt/zeppelin-${ZEPPELIN_VERSION}-bin-all" /opt/zeppelin

ENV ZEPPELIN_HOME="/opt/zeppelin"
ENV PATH="$ZEPPELIN_HOME/bin:$PATH"
ENV ZEPPELIN_ADDR="0.0.0.0"
ENV ZEPPELIN_PORT="8080"

# 10. Configuração do Zeppelin
RUN mkdir -p $ZEPPELIN_HOME/logs $ZEPPELIN_HOME/run \
    && echo '<?xml version="1.0"?>' > $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '<configuration>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '  <property>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '    <name>zeppelin.server.addr</name>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '    <value>0.0.0.0</value>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '    <description>Server binding address</description>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '  </property>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '  <property>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '    <name>zeppelin.server.port</name>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '    <value>8080</value>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '    <description>Server port</description>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '  </property>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && echo '</configuration>' >> $ZEPPELIN_HOME/conf/zeppelin-site.xml \
    && chmod 644 $ZEPPELIN_HOME/conf/zeppelin-site.xml

# 11. Configuração de permissões e limpeza
RUN chmod +x $ZEPPELIN_HOME/bin/zeppelin.sh \
    && mkdir -p /app/notebooks

RUN rm -rf $ZEPPELIN_HOME/notebook/*

# Porta exposta
EXPOSE 8080

# Comando de inicialização
CMD ["/opt/zeppelin/bin/zeppelin.sh"]