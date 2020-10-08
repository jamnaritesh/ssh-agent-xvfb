# FROM openjdk:8-jdk-buster

FROM adoptopenjdk/openjdk8:jdk8u262-b10-alpine

ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG JENKINS_AGENT_HOME=/home/${user}

ENV JENKINS_AGENT_HOME ${JENKINS_AGENT_HOME}

RUN mkdir -p "${JENKINS_AGENT_HOME}" \
    && addgroup -g "${gid}" "${group}" \
# Set the home directory (h), set user and group id (u, G), set the shell, don't ask for password (D)
    && adduser -h "${JENKINS_AGENT_HOME}" -u "${uid}" -G "${group}" -s /bin/bash -D "${user}" \
# Unblock user
    && passwd -u "${user}"

# setup SSH server
RUN apk update --no-cache \
    && apk add --no-cache \
        bash \
        openssh

RUN sed -i /etc/ssh/sshd_config \
        -e 's/#PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/#PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/#SyslogFacility.*/SyslogFacility AUTH/' \
        -e 's/#LogLevel.*/LogLevel INFO/' \
    && mkdir /var/run/sshd

VOLUME "${JENKINS_AGENT_HOME}" "/tmp" "/run" "/var/run"
WORKDIR "${JENKINS_AGENT_HOME}"

RUN apk update --no-cache  && apk add --no-cache  curl xvfb chromium
# COPY pin_nodesource /etc/apt/preferences.d/nodesource

ADD xvfb-chromium /usr/bin/xvfb-chromium

RUN ["chmod", "+x", "/usr/local/bin/xvfb-chromium "] 

RUN ln -s /usr/bin/xvfb-chromium /usr/bin/google-chrome

COPY setup-sshd /usr/local/bin/setup-sshd
RUN ["chmod", "+x", "/usr/local/bin/setup-sshd"] 

EXPOSE 22

ENTRYPOINT ["setup-sshd"]

