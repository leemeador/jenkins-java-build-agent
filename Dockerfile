FROM ubuntu:bionic

LABEL maintainer="lee@leemeador.com"

# Begin:      https://hub.docker.com/r/bibinwilson/jenkins-slave
# Usage info: https://devopscube.com/docker-containers-as-build-slaves-jenkins/

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get -qy full-upgrade && \
    apt-get install -qy git && \
# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \
# Install JDK 8 and JDK 11
    apt-get install -qy openjdk-11-jdk && \
    apt-get install -qy openjdk-8-jdk && \
# Install maven 3.3.9 and 3.6.0
    mkdir /opt/tools && \
    wget http://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz -P /tmp && \
    sudo tar xf /tmp/apache-maven-3.3.9-bin.tar.gz -C /opt/tools && \
    wget http://archive.apache.org/dist/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz -P /tmp && \
    sudo tar xf /tmp/apache-maven-3.6.0-bin.tar.gz -C /opt/tools && \
# Install git
    sudo apt-get install git && \
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
