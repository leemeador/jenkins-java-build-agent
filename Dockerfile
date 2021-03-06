FROM ubuntu:bionic

LABEL maintainer="lee@leemeador.com"

ENV JENKINS_AGENT="ot-agent-java" \
    JAVA_HOME="/usr/lib/jvm/java-8" \
    M2_HOME="/opt/tools/apache-maven-3.6.0" \
    GRADLE_HOME="/opt/tools/gradle-2.2.1"
ENV PATH=${M2_HOME}/bin:${GRADLE_HOME}/bin:${PATH}

# Begin:      https://hub.docker.com/r/bibinwilson/jenkins-slave
# Usage info: https://devopscube.com/docker-containers-as-build-slaves-jenkins/

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy apt-transport-https ca-certificates curl gnupg2 software-properties-common git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 8 and JDK 11
    apt-get install -qy openjdk-11-jdk && \
    apt-get install -qy openjdk-8-jdk && \
    update-java-alternatives --set java-1.8.0-openjdk-amd64 && \
    ln -s /usr/lib/jvm/java-11-openjdk-amd64 /usr/lib/jvm/java-11 && \
    ln -s /usr/lib/jvm/java-8-openjdk-amd64 /usr/lib/jvm/java-8 && \
# Install maven 3.3.9 and 3.6.0
    mkdir /opt/tools && \
    wget --no-verbose http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt/tools && \
    wget --no-verbose http://archive.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp && \
    tar xf /tmp/apache-maven-3.6.0-bin.tar.gz -C /opt/tools && \
# Install Unzip
    apt-get install unzip && \
# install gradle 2.2.1
    wget --no-verbose https://services.gradle.org/distributions/gradle-2.2.1-bin.zip -P /tmp && \
    unzip -d /opt/tools /tmp/gradle-2.2.1-bin.zip && \
# Cleanup old packages
    apt-get -qy autoremove && \
# Add user cicduser to the image
    adduser --quiet --uid 10011 cicduser && \
# Set password for the cicduser user (you may want to alter this).
    echo "cicduser:jenkins" | chpasswd

#ADD settings.xml /home/jenkins/.m2/
## Copy authorized keys
#COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys
#
#RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
#    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
