# My ubuntu devops development docker container

# DOCKER-VERSION 0.0.1
FROM      ubuntu:14.04

MAINTAINER Diep Le <dieple1@gmail.com>

# make sure the package repository is up to date
RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get -y update

# install python-software-properties (so you can do add-apt-repository)
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -q python-software-properties software-properties-common

# install SSH server so we can connect multiple times to the container
RUN apt-get -y install openssh-server && mkdir /var/run/sshd

# install oracle java from PPA
RUN add-apt-repository ppa:webupd8team/java -y
RUN apt-get update
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN apt-get -y install oracle-java8-installer && apt-get clean

# Set oracle java as the default java
RUN update-java-alternatives -s java-8-oracle
RUN echo "export JAVA_HOME=/usr/lib/jvm/java-8-oracle" >> ~/.bashrc

# install utilities
RUN apt-get -y install vim git sudo zip bzip2 fontconfig curl byobu htop man wget

# install awscli
RUN apt-get install -yq --no-install-recommends awscli groff-base

# install python
# RUN apt-get install -y python python-dev python-pip python-virtualenv

# install maven
RUN apt-get -y install maven

# install node.js
RUN curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
RUN apt-get install -y nodejs

# install yeoman
RUN npm install -g yo bower grunt-cli

# install JHipster
RUN npm install -g generator-jhipster@2.19.0

# configure the "devops" and "root" users
RUN echo 'root:devops' |chpasswd
RUN groupadd devops && useradd devops -s /bin/bash -m -g devops -G devops && adduser devops sudo
RUN echo 'devops:devops' |chpasswd

# install the sample app to download all Maven dependencies
RUN cd /home/devops && \
    wget https://github.com/jhipster/jhipster-sample-app/archive/v2.20.0.zip && \
    unzip v2.20.0.zip && \
    rm v2.20.0.zip
RUN cd /home/devops/jhipster-sample-app-2.19.0 && npm install
RUN cd /home && chown -R devops:devops /home/devops
RUN cd /home/devops/jhipster-sample-app-2.19.0 && sudo -u devops mvn dependency:go-offline


##
# Install Tomcat inside the container
##
ENV CATALINA_HOME /home/devops/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

# see https://www.apache.org/dist/tomcat/tomcat-8/KEYS
RUN gpg --keyserver pool.sks-keyservers.net --recv-keys \
	05AB33110949707C93A279E3D3EFE6B686867BA6 \
	07E48665A34DCAFAE522E5E6266191C37C037D42 \
	47309207D818FFD8DCD3F83F1931D684307A10A5 \
	541FBE7D8F78B25E055DDEE13C370389288584E7 \
	61B832AC2F1C5A90F0F9B00A1C506407564C17A3 \
	79F7026C690BAA50B92CD8B66A3AD3F4F22C4FED \
	9BA44C2621385CB966EBA586F72C284D731FABEE \
	A27677289986DB50844682F8ACB77FC2E86E29AC \
	A9C5DF4D22E99998D9875A5110C01C5A2F6059E7 \
	DCFD35E0BF8CA7344752DE8B6FB21E8933C60243 \
	F3A04C595DB5B6A5F1ECA43E3B7BBB100D811BBE \
	F7DA48BB64BCB84ECBA7EE6935CD23C10D498E23

ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.0.26
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --verify tomcat.tar.gz.asc \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

# expose the working directory, the Tomcat port, the BrowserSync ports, the SSHD port, and run SSHD
VOLUME ["/apps/sandboxes"]
EXPOSE 8080 3000 3001 22
CMD    /usr/sbin/sshd -D
#CMD ["catalina.sh", "run"]
